# Boxy The Game

Retro plošinovka s „.exe“ hororovou atmosférou. Postavy, mapy a příběh původně vznikly v Pi Learn to Code.

- [CHARACTERS.md](CHARACTERS.md) – postavy
- [MAPS.md](MAPS.md) – mapy
- [ANIMATIONS.md](ANIMATIONS.md) – animované dlaždice
- [STORY.md](STORY.md) – scénky a příběh

## Hra (Godot 4)

Projekt je ve složce [`game/`](game/).

### Spuštění na Android telefonu
1. Nainstaluj **Godot Engine 4** z Google Play.
2. Stáhni tento repozitář jako ZIP (na GitHubu: Code → Download ZIP, větev `ccr-c8626202-txpwsg`) a rozbal ho.
3. V Godotu dej **Import**, vyber soubor `game/project.godot` a projekt otevři.
4. Spusť hru tlačítkem ▶ vpravo nahoře.

### Ovládání
- Telefon: tlačítka ◀ ▶ vlevo dole a ▲ (skok) vpravo dole
- Klávesnice: šipky a mezerník

### Co už funguje (prototyp)
- Hillwood Zone: tráva, hlína, voda a stromy z tvých map
- Boxy běhá a skáče a má animaci stání a chůze z tvých spritů
- Dr. Maniac chodí sem a tam: skok na hlavu ho porazí, dotek z boku tě vrátí na start
- Pád do vody vrací na start

### Úprava úrovně
Úroveň je zapsaná jako text v `game/scripts/main.gd` (proměnná `LEVEL`):
`#` tráva, `d` hlína, `~` voda, `^` ostny, `=` pohyblivá plošina, `F` cíl, `P` start hráče, `M` Dr. Maniac, `.` vzduch.

### Sprity
`tools/extract_sprites.py` vyřízne sprity 13×13 (jako v Pi Learn to Code) ze screenshotů v `reference/characters/`:
```
python3 tools/extract_sprites.py reference/characters/al-classic.png game/assets/sprites/al-classic
```
