"""Vyřízne sprity ze screenshotů editoru Pi Learn to Code.
Postavy v editoru mají 13x13 pixelů. Každý snímek se vloží do buňky 16x16 (zarovnaný dolů na střed)."""
import sys
from PIL import Image

N = 13
CELL = 16
CHECKER = [(208, 208, 208), (156, 156, 156)]  # šachovnice = průhlednost

def extract(path, out):
    im = Image.open(path).convert('RGB')
    k = im.size[0] / 2000
    x0, y0, size, step = 365.4 * k, 368.8 * k, 199.3 * k, 375.5 * k
    s = size / N
    sheet = Image.new('RGBA', (CELL * 4, CELL), (0, 0, 0, 0))
    ox, oy = (CELL - N) // 2, CELL - N
    for f in range(4):
        for j in range(N):
            for i in range(N):
                col = im.getpixel((int(x0 + f * step + (i + .5) * s), int(y0 + (j + .5) * s)))
                if col == CHECKER[(i + j) % 2]:
                    continue
                sheet.putpixel((f * CELL + ox + i, oy + j), col + (255,))
    sheet.save(out + '.png')

if __name__ == '__main__':
    extract(sys.argv[1], sys.argv[2])
