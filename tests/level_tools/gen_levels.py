"""Write LevelN.tscn files from a JSON layout and run the headless checker on them.

usage: python gen_levels.py layouts.json [--check]
layouts.json: {"7": {"player": [x, y], "planets": [["Mars", x, y], ...]}, ...}
Set GODOT to the console Godot executable if it is not at the default path.
"""
import json
import os
import subprocess
import sys
from pathlib import Path

PROJECT = Path(__file__).resolve().parents[2]
GODOT = os.environ.get(
    "GODOT", r"C:\Users\mihir\OneDrive\Desktop\Godot V4.4.1\Godot_v4.4.1-stable_win64_console.exe")
OUT = Path(__file__).parent / "runs"

RES = {
    "Earth": ("uid://cpgl4bxh62l87", "res://Assets/Earth.tres"),
    "Earth2": ("uid://dijs1qq1y05i1", "res://Assets/Earth2.tres"),
    "Mars": ("uid://rn22vv13aith", "res://Assets/Mars.tres"),
}


def scene_text(n: int, layout: dict) -> str:
    used = sorted({p[0] for p in layout["planets"]})
    lines = [f"[gd_scene load_steps={len(used) + 2} format=3]", ""]
    lines.append('[ext_resource type="PackedScene" uid="uid://w6a8ecucjs34" path="res://Scenes/planet.tscn" id="1_planet"]')
    for kind in used:
        uid, path = RES[kind]
        lines.append(f'[ext_resource type="Resource" uid="{uid}" path="{path}" id="2_{kind.lower()}"]')
    lines += ["", f'[node name="Level{n}" type="Node2D"]', ""]
    for i, (kind, x, y) in enumerate(layout["planets"]):
        name = "Planet" if i == 0 else f"Planet{i + 1}"
        lines += [
            f'[node name="{name}" parent="." instance=ExtResource("1_planet")]',
            f"position = Vector2({x}, {y})",
            f'res = ExtResource("2_{kind.lower()}")',
            "",
        ]
    px, py = layout["player"]
    lines += ['[node name="player_pos" type="Marker2D" parent="."]', f"position = Vector2({px}, {py})", ""]
    return "\n".join(lines)


def check(levels: list[str]) -> None:
    OUT.mkdir(exist_ok=True)
    env = {**os.environ, "GODOT_MCP_RUNTIME": "0"}
    procs = {}
    for n in levels:
        f = open(OUT / f"L{n}.txt", "w")
        procs[n] = (subprocess.Popen(
            [GODOT, "--headless", "--fixed-fps", "60", "--path", str(PROJECT), "--script",
             "res://tests/level_check.gd", "--", f"res://Scenes/Level{n}.tscn"],
            stdout=f, stderr=subprocess.STDOUT, env=env), f)
    for n, (p, f) in procs.items():
        try:
            p.wait(timeout=1500)
        except subprocess.TimeoutExpired:
            p.kill()
            print(f"Level{n}: TIMEOUT")
        f.close()
        text = (OUT / f"L{n}.txt").read_text(errors="replace")
        res = [l for l in text.splitlines() if l.startswith("RESULT ")]
        if not res:
            print(f"Level{n}: no result\n" + text[-1500:])
            continue
        r = json.loads(res[0][7:])
        rates = [s["hit_rate"] for s in r["steps"]]
        print(f"Level{n}: solvable={r['solvable']} planets={r['planets']}")
        for s in r["steps"]:
            print(f"   from {s['from']} -> {s['target']:8} hit_rate={s['hit_rate']:.3f} "
                  f"target_hits={s['target_hits']:3} shot=({s['angle']}deg, {s['strength']}) "
                  f"options={' '.join(s.get('options', []))}")
        if rates:
            print(f"   min_hit={min(rates):.3f} mean_hit={sum(rates)/len(rates):.3f}")


if __name__ == "__main__":
    layouts = json.loads(Path(sys.argv[1]).read_text())
    for n, layout in layouts.items():
        if "player" in layout:
            (PROJECT / "Scenes" / f"Level{n}.tscn").write_text(scene_text(int(n), layout), newline="\n")
    if "--check" in sys.argv:
        check(list(layouts.keys()))
