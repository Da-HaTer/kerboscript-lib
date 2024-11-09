# Aerospace & Aviation Library

This repository contains a collection of **algorithms and code snippets** for aircraft and spacecraft development using the [Kerbal Space Program (KSP)](https://www.kerbalspaceprogram.com/) simulator and the [kOS scripting language](https://ksp-kos.github.io/KOS/). The code focuses on **autopilot systems, orbital mechanics, guidance, ascent, and landing algorithms** that can be used to automate various aspects of space and flight missions.

While the code may not be fully organized, it demonstrates practical solutions for challenges encountered in aerospace simulations, using **mathematical and physical equations** ,  **PID control loops** and **control theory** to create functional, autonomous aircraft and spacecraft.

## Features

The **Aerospace and Aviation Library** was developed as a personal project to explore aerospace engineering concepts in a simulation environment. Key components of the library include:
- **Launch Window Calculation**: Calculates the optimal time to launch to achieve a desired orbital or interplanetary trajectory.
- **Ascent Algorithm**: Automates efficient rocket ascents from a planetary surface into orbit.
- **Orbital Insertion Algorithm**: Handles the process of entering a stable orbit from an ascent trajectory.
- **Orbital Plane Change Maneuvers Calculation**: Implements calculations based on **Kepler's Laws** for orbital plane adjustments.
- **Hohmann Transfer Calculations**: Calculates efficient orbital transfer maneuvers for changing altitudes between two orbits.
- **Orbital Rendezvous Calculation**: Enables precise timing and velocity adjustments to bring two spacecraft into the same orbit and position for rendezvous.
- **Rocket Equation Burn Time Calculations**: Uses the **Tsiolkovsky rocket equation** to compute burn times based on delta-v and fuel consumption.
- **SpaceX-style Rocket Landing Calculations and Maneuvers**: Simulates the trajectory and control required for vertical rocket landings, similar to SpaceX's Falcon 9.
- **Trajectory Integration (Forecast)**: Integrates spacecraft trajectories to predict future positions and orbital paths.
- **Autopilot for Aircraft**: Utilizes **roll and pitch PID loops** to provide a stable autopilot for atmospheric flight control.

---


## Project Status

The project is currently **on hold**, with plans to revisit in the future, and while the code snippets demonstrate significant achievements in the simulation of aerospace operations, future development is always a possibility:

> "Once you're in low Earth orbit, you're halfway to anywhere"

— and this code gets you there.

---

## Demo Videos

- **Fully autonomous mission to the moon**  
  <a href="https://www.youtube.com/watch?v=RjdYkuKnw3U" target="_blank">
    <img src="https://github.com/user-attachments/assets/398e8900-15cc-4391-a230-066ac7a6e78a" alt="Autopilot System" width="300" >
  </a>

- **SpaceX Style Landing System Demo**  
  <a href="https://www.youtube.com/watch?v=RjdYkuKnw3U" target="_blank">
    <img src="https://github.com/user-attachments/assets/35821510-bf1c-4fbd-b4bb-f7c94cbfab00" alt="Landing System" width="300" >
  </a>

- **Aircraft Autopilot**  
  <a href="https://drive.google.com/file/d/1A1X506umgafYMnCnrJDHG14_7Cm_HafL/preview" target="_blank">
    <img src="https://github.com/user-attachments/assets/d5a679ab-0fb0-47b4-a6ee-5ec1b8f8f6e1" alt="Plane Autopilot" width="300" >
  </a>
  
  <a href="https://drive.google.com/file/d/1A1X506umgafYMnCnrJDHG14_7Cm_HafL/preview" target="_blank">
    <img src="https://github.com/user-attachments/assets/4eff539e-bb7a-4754-b9f9-b903c8a3f156" alt="Plane Autopilot" width="300" >
  </a>


---

## Technologies and Tools
- **PID Loops and Control Theory**: The code heavily utilizes **proportional-integral-derivative (PID)** control loops, a key mechanism in control systems, to achieve stable flight and navigation.
- **Mathematical and Physics equations**: The code also heavily relies on Newton's mechanics and Kepler's dynamics, spherical trigonometry and much more, with plans to provide detailed descriptions/ derivations in the future.

---

## Future Work

- **Code Refactoring and Organization**: While the code is functional, further refactoring, organization and demos are planned to improve usability and readability.
- **Extended Aerospace Algorithms**: Potential future updates may include **more complex orbital Ascent algorithms**, **reentry simulations**, and **Interplanetary maneuvers**.
- **Integration of Machine Learning Algorithms**: Potential improvements of control systems with Data Science oriented approaches.

---

## References

1. [Kerbal Space Program (KSP)](https://www.kerbalspaceprogram.com/)
2. [kOS Scripting Language](https://ksp-kos.github.io/KOS/)
3. [Intro to KOS Programming](https://www.youtube.com/watch?v=fNlAME5eU3o&list=PLb6UbFXBdbCrvdXVgY_3jp5swtvW24fYv&pp=iAQB)

---
