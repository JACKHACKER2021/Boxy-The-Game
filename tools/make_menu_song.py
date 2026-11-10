"""Vygeneruje retro chiptune skladbu pro menu Boxy The Game (vlastní melodie)."""
import numpy as np, wave, sys

SR = 44100
BPM = 132
BEAT = 60 / BPM
STEP = BEAT / 4  # šestnáctinová nota

def freq(n):  # MIDI číslo -> Hz
    return 440 * 2 ** ((n - 69) / 12)

def square(f, n, duty=0.5):
    t = np.arange(n) / SR
    return np.where((t * f) % 1 < duty, 1.0, -1.0)

def triangle(f, n):
    t = np.arange(n) / SR
    return 2 * np.abs(2 * ((t * f) % 1) - 1) - 1

def env(n, a=0.005, r=0.6):
    e = np.ones(n)
    ai = int(a * SR); e[:ai] = np.linspace(0, 1, ai)
    e *= np.exp(-np.linspace(0, 1, n) * r * 3)
    return e

def render(track, wavefn, vol, length):
    out = np.zeros(length)
    pos = 0
    for note, steps in track:
        n = int(steps * STEP * SR)
        if note is not None:
            tone = wavefn(freq(note), n) * env(n)
            out[pos:pos + n] += tone[:max(0, min(n, length - pos))] * vol
        pos += n
    return out

# Akordy: Am - F - C - G (2 takty každý = 32 šestnáctin)
C, D, E, F, G, A, B = 60, 62, 64, 65, 67, 69, 71
melA = [(A+12,2),(E+12,2),(C+12,2),(E+12,2),(A+12,4),(B+12,2),(C+24,2),
        (B+12,4),(G+12,4),(E+12,4),(None,4),
        (F+12,2),(A+12,2),(C+24,2),(A+12,2),(F+12,4),(G+12,2),(A+12,2),
        (G+12,4),(E+12,4),(C+12,8),
        (C+12,2),(E+12,2),(G+12,2),(C+24,2),(B+12,4),(G+12,4),
        (E+12,4),(G+12,4),(C+24,8),
        (D+12,2),(G+12,2),(B+12,2),(D+24,2),(C+24,4),(B+12,4),
        (A+12,4),(G+12,4),(B+12,8)]
melB = [(E+24,4),(D+24,2),(C+24,2),(B+12,4),(A+12,4),(C+24,8),(A+12,8),
        (F+12,4),(A+12,4),(C+24,4),(F+24,4),(E+24,8),(C+24,8),
        (G+12,2),(C+24,2),(E+24,2),(G+24,2),(E+24,4),(C+24,4),(G+12,8),(E+12,8),
        (D+12,4),(G+12,4),(B+12,4),(D+24,4),(B+12,6),(None,2),(G+12,8)]
chords = [A-24, F-24, C-12, G-24]

def bass_part():
    tr = []
    for root in chords:
        for _ in range(4):
            tr += [(root,2),(root+12,2),(root+7,2),(root+12,2)]
    return tr

def arp_part():
    tr = []
    for root, third in zip(chords, [3, 4, 4, 4]):
        for _ in range(8):
            tr += [(root+24,1),(root+24+third,1),(root+24+7,1),(root+36,1)]
    return tr

def drums(length, bars):
    out = np.zeros(length)
    rng = np.random.default_rng(7)
    for s in range(bars * 16):
        p = int(s * STEP * SR)
        if s % 8 == 0:  # kopák
            n = int(0.12 * SR); t = np.arange(n) / SR
            k = np.sin(2 * np.pi * (120 * np.exp(-t * 30) + 45) * t) * np.exp(-t * 25)
            out[p:p+n] += k[:len(out[p:p+n])] * 0.55
        if s % 8 == 4:  # virbl
            n = int(0.10 * SR)
            sn = rng.uniform(-1, 1, n) * np.exp(-np.arange(n) / SR * 30)
            out[p:p+n] += sn[:len(out[p:p+n])] * 0.3
        if s % 2 == 0:  # hihat
            n = int(0.03 * SR)
            hh = rng.uniform(-1, 1, n) * np.exp(-np.arange(n) / SR * 120)
            out[p:p+n] += hh[:len(out[p:p+n])] * 0.1
    return out

section = int(32 * 4 * STEP * SR)  # 8 taktů
def part(mel):
    L = section
    lead = render(mel, lambda f, n: square(f, n, 0.25), 0.18, L)
    bass = render(bass_part(), triangle, 0.35, L)
    arp = render(arp_part(), lambda f, n: square(f, n, 0.125), 0.05, L)
    return lead + bass + arp + drums(L, 8)

song = np.concatenate([part(melA), part(melB), part(melA), part(melB)])
song = song / np.max(np.abs(song)) * 0.85
pcm = (song * 32767).astype(np.int16)
out = sys.argv[1] if len(sys.argv) > 1 else 'menu_song.wav'
with wave.open(out, 'wb') as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes(pcm.tobytes())
print(out, len(song) / SR, 's')
