"""Vyřízne 16x16 sprity ze screenshotů editoru Pi Learn to Code."""
import sys, os
from PIL import Image

N = 16

def cells(im, x0, y0, size):
    s = size / N
    return [[im.getpixel((int(x0 + (i + .5) * s), int(y0 + (j + .5) * s))) for i in range(N)] for j in range(N)]

def close(a, b, t=18):
    return all(abs(p - q) <= t for p, q in zip(a, b))

def extract(path, out_prefix):
    im = Image.open(path).convert('RGB')
    k = im.size[0] / 2000
    x0, y0, size, step = 365 * k, 369 * k, 199 * k, 375.5 * k
    frames = []
    for f in range(4):
        c = cells(im, x0 + f * step, y0, size)
        frames.append(c)
    # barvy šachovnice podle parity z rohových buněk všech snímků
    checker = {0: (208, 208, 208), 1: (156, 156, 156)}
    sheet = Image.new('RGBA', (N * 4, N), (0, 0, 0, 0))
    for f, c in enumerate(frames):
        for j in range(N):
            for i in range(N):
                col = c[j][i]
                if close(col, checker[0], 6) or close(col, checker[1], 6):
                    continue
                sheet.putpixel((f * N + i, j), col + (255,))
    sheet.save(out_prefix + '.png')

if __name__ == '__main__':
    extract(sys.argv[1], sys.argv[2])
