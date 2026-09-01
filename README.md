![PLANET LOOP!](.IchioBanner.png)

# 🪐 Planet Loop

> **Shoot. Orbit. Loop. Repeat.**

**Planet Loop** is a small physics-based space game made in **Godot** for **GMTK Game Jam 2025**.

You control a satellite launched through space by aiming and charging a shot with your mouse. Your goal is to use planetary gravity to complete a **full rotation around each planet**.

Complete an orbit and the planet disappears. Miss your trajectory and crash into the planet? **You reset back to your starting position and try again.**

I wasn't able to submit the game before the GMTK Game Jam deadline, but I decided to keep the project as a playable prototype and experiment with orbital physics and game mechanics.

---

## 🎮 Gameplay

The core gameplay is simple:

**Aim → Launch → Orbit → Destroy → Repeat**

You start next to a planet with your satellite ready to launch.

Use the mouse to choose your launch direction and strength. Once launched, the satellite travels freely through space while being affected by the planet's gravity.

Your objective is to make the satellite travel **one complete loop around the planet**.

### 🪐 Complete an Orbit

Successfully make one full rotation around the planet and the planet is destroyed/disappears.

The satellite then returns to a state where you can launch it again toward the next planet.

### 💥 Crash into the Planet

Things don't always go according to plan.

If the satellite crashes directly into the planet, the attempt fails and the satellite **resets to its original position**, allowing you to try the shot again.

The challenge is finding the right combination of **angle and launch strength** to produce a successful orbit.

---

## 🕹️ Controls

| Input                   | Action                                    |
| ----------------------- | ----------------------------------------- |
| 🖱️ Mouse position      | Aim the satellite                         |
| ↔️ Mouse distance       | Determines launch strength                |
| 🖱️ Mouse click/release | Launch the satellite                      |
| 💥 Crash                | Satellite resets to its starting position |

The farther you pull the mouse away from the satellite, the stronger the launch.

---

## 🎯 Objective

For every planet:

1. Aim the satellite.
2. Choose your launch strength.
3. Launch the satellite.
4. Use the planet's gravity to enter an orbit.
5. Complete **one full rotation**.
6. The planet disappears.
7. Move on to the next planet.

If you crash into the planet, **your satellite resets and you can try again**.

The goal is to figure out the physics and learn how to make the perfect shot.

---

## ✨ Features

* 🛰️ Physics-based satellite movement
* 🪐 Planetary gravity
* 🖱️ Mouse-based aiming system
* 💪 Distance-based launch strength
* 🔄 Orbital gameplay
* 💥 Planet destruction after completing an orbit
* ♻️ Satellite reset after crashing
* 🌌 Simple space-themed environment
* 🎯 Skill-based trajectory planning

---

## 🎬 Gameplay

> **Add a gameplay GIF here!**

A short gameplay GIF is recommended here so visitors can immediately understand the game without having to download it.

```markdown
![Planet Loop Gameplay](assets/gameplay.gif)
```

You can replace the path above with wherever you store your GIF.

### 📸 Screenshots

> Add screenshots of the game here.

```markdown
![Gameplay Screenshot](assets/screenshot1.png)
![Orbiting a Planet](assets/screenshot2.png)
```

---

## 🚀 Play the Game

If a playable build is available, download it below:

**[▶️ Download / Play Planet Loop](#)**

> Replace the link above with your GitHub Releases page or itch.io page once you have uploaded a build.

For the best GitHub experience, I recommend uploading Windows/Linux builds through **GitHub Releases** rather than putting the executable directly in the repository.

---

## 🛠️ Built With

* **Godot**
* **GDScript**
* 2D physics
* Custom orbital/planetary gravity mechanics

---

## 🧠 How It Works

The main gameplay mechanic revolves around **orbital motion**.

Rather than directly controlling the satellite, the player gives it an initial velocity by launching it toward a planet.

The satellite is then affected by the planet's gravitational force, causing its trajectory to curve.

A successful launch produces a trajectory that allows the satellite to travel around the planet and complete a full rotation.

This makes every shot a small physics puzzle:

> **How much speed do I need, and at what angle?**

Too little or too much velocity can result in a failed orbit, while hitting the planet causes the satellite to reset.

---

## 🎮 Game Jam

### GMTK Game Jam 2025

Planet Loop was originally created for **GMTK Game Jam 2025**.

Unfortunately, I wasn't able to submit the game before the deadline.

Even though it missed the submission window, I decided to keep the project and share it as a small game-development experiment.

The project gave me an opportunity to experiment with:

* Godot's physics system
* Gravitational interactions
* Orbital trajectories
* Mouse-based controls
* Game-state resets
* Designing a simple gameplay loop around physics

---

## 🚧 Future Improvements

Planet Loop is currently a small prototype, but there are plenty of directions it could be taken.

### Gameplay

* More levels
* Increasing difficulty
* Multiple planets in a single level
* Different planet sizes and gravity strengths
* Moving planets
* Obstacles and hazards
* More complex orbital paths

### Progression

* Score based on launch efficiency
* Limited attempts
* Level progression
* High scores
* Unlockable planets
* Increasingly difficult orbital challenges

### Presentation

* Better visual effects
* Planet destruction animations
* Satellite trails
* Particle effects
* Background effects
* Sound effects
* Music
* Menus and UI
* Win/lose screens

---

## 📦 Running the Project

To experiment with the project yourself:

1. Install **Godot**.
2. Clone this repository.
3. Open the project in Godot.
4. Import/open the project.
5. Run the main scene.

```bash
git clone https://github.com/YOUR_USERNAME/planet-loop.git
```

Then open the project in Godot and press **Run**.

---

## 📜 License

This project is provided as-is for learning, experimentation, and game-development purposes.

If you use any of the project's code or assets in another project, please check the individual asset/code licenses where applicable.

---

<p align="center">
  🛰️ <b>Planet Loop</b><br>
  <i>Shoot. Orbit. Loop. Repeat.</i>
</p>

<p align="center">
  Made with ❤️ and Godot for GMTK Game Jam 2025
</p>
