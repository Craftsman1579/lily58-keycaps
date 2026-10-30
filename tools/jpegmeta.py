# JPEG-Metadaten pruefen bzw. entfernen.
#   jpegmeta.py check <datei>        -> APP-Segmente, EXIF-GPS, Kameramodell, Ausrichtung, Daten hinter dem Bild
#   jpegmeta.py strip <ein> <aus>    -> alle APP1..APP15-Segmente (EXIF, XMP, ...) und alles nach EOI entfernen
import struct, sys


def segments(d):
    i = 2
    while i < len(d):
        if d[i] != 0xFF:
            break
        m = d[i + 1]
        if m == 0xDA:                      # Start of Scan: Rest bis EOI ist Bilddaten
            yield m, i, None
            return
        n = struct.unpack('>H', d[i + 2:i + 4])[0]
        yield m, i, d[i + 4:i + 2 + n]
        i += 2 + n


def exif_info(app1):
    if not app1.startswith(b'Exif\0\0'):
        return {}
    t = app1[6:]
    bo = '<' if t[:2] == b'II' else '>'
    rd = lambda fmt, o: struct.unpack(bo + fmt, t[o:o + struct.calcsize(fmt)])[0]
    info = {}
    def ifd(o, names):
        for k in range(rd('H', o)):
            e = o + 2 + 12 * k
            tag, typ, cnt = rd('H', e), rd('H', e + 2), rd('I', e + 4)
            if tag in names:
                if typ == 2:
                    off = e + 8 if cnt <= 4 else rd('I', e + 8)
                    info[names[tag]] = t[off:off + cnt].rstrip(b'\0').decode(errors='replace')
                elif typ == 3:
                    info[names[tag]] = rd('H', e + 8)
                else:
                    info[names[tag]] = rd('I', e + 8)
    ifd(rd('I', 4), {0x0110: 'Modell', 0x0112: 'Ausrichtung', 0x8825: 'GPS-IFD'})
    if 'GPS-IFD' in info:
        o = info['GPS-IFD']; info['GPS-Eintraege'] = rd('H', o)
    return info


mode = sys.argv[1]
d = open(sys.argv[2], 'rb').read()
if mode == 'check':
    eoi = d.rfind(b'\xff\xd9', 0, len(d))
    apps = []
    info = {}
    for m, i, body in segments(d):
        if 0xE1 <= m <= 0xEF:
            apps.append(f'APP{m - 0xE0}')
            if m == 0xE1 and body is not None:
                info.update(exif_info(body))
    # Daten hinter dem ersten EOI nach dem Scan (Motion Photo haengt ein Video an)
    sos = d.find(b'\xff\xda')
    first_eoi = d.find(b'\xff\xd9', sos)
    trailing = len(d) - (first_eoi + 2)
    print(f"{sys.argv[2].split('/')[-1]}: {len(d)/1048576:.1f} MB, Segmente {sorted(set(apps))}, {info}, "
          f"nach Bildende noch {trailing/1048576:.1f} MB")
else:
    out = bytearray(d[:2])
    for m, i, body in segments(d):
        if body is None:
            sos = i
            break
        if not (0xE1 <= m <= 0xEF):
            out += d[i:i + 4 + len(body)]
    end = d.find(b'\xff\xd9', sos)
    out += d[sos:end + 2]
    open(sys.argv[3], 'wb').write(out)
    print(f"{sys.argv[3].split('/')[-1]}: {len(out)/1048576:.2f} MB ohne Metadaten")
