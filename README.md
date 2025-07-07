# Ark4de I0 - Cartesian Spider Robot Arcade Game

A final robotics assignment project featuring a cartesian spider robot programmed to create an interactive arcade-style game. This project combines robotics control, computer vision, and web-based user interface to deliver an engaging gaming experience.

## Project Description

Ark4de I0 is an innovative robotics project that transforms a cartesian spider robot into an interactive arcade game platform. The system integrates real-time robot control with computer vision for object detection and scoring, all wrapped in a modern web-based interface. Players control the robot to collect objects and earn points in an arcade-style gaming environment.

The project demonstrates advanced robotics concepts including:
- Precise cartesian coordinate control
- Real-time computer vision processing
- Interactive human-machine interface
- Game mechanics and scoring systems

## Control Options

The game supports multiple control methods:

### PlayStation 4 Controller
- Full wireless controller support for intuitive gameplay

### Keyboard Controls
- **WASD/Arrow Keys**: Robot movement control
  - W/↑: Move forward
  - A/←: Move left
  - S/↓: Move backward
  - D/→: Move right
- **N**: Crane/gripper open action
- **M**: Crane/gripper close action
- **L**: Light toggle control

## Technologies Used

- **MATLAB**: Core robotics control system and game logic
- **Computer Vision**: Object detection and tracking algorithms
- **HTML/CSS/JavaScript**: Interactive web-based user interface
- **Tailwind CSS**: Modern responsive styling framework

## Requirements

### Hardware Requirements
- Cartesian spider robot system
- USB camera for computer vision
- PlayStation 4 controller (optional)
- Computer with MATLAB installation

### Software Requirements
- MATLAB R2019b or later
- Computer Vision Toolbox
- Image Processing Toolbox
- Web browser (Chrome, Firefox, Safari, or Edge)

## Installation and Usage

### Installation
1. Clone the repository to your local machine
2. Ensure MATLAB is installed with required toolboxes
3. Connect the cartesian spider robot to your computer
4. Set up the camera for computer vision processing
5. (Optional) Connect PlayStation 4 controller

### Usage
1. Open MATLAB and navigate to the project directory
2. Run the main script:
   ```matlab
   game = ARK4DE();
   ```
3. The arcade interface will launch in your default web browser
4. Follow the on-screen instructions to start playing
5. Use your preferred control method (keyboard or PS4 controller)
6. Collect objects to earn points and achieve high scores

### Game Flow
1. **Welcome Screen**: Click START to begin
2. **Game Setup**: View rules and enter player name
3. **Gameplay**: Control the robot to collect objects within the time limit
4. **Scoring**: Earn points based on collected objects
5. **Leaderboard**: View your score and compete with other players

## Gallery

### Game Screenshots

<p align="center">
  <img src="https://github.com/Big-Lolo/Ark4de-I0/blob/main/assets/images/robot1.jpg" alt="Game Interface" width="200"/>
  <br>
  <em>Main arcade interface showing the game in action</em>
</p>

<p align="center">
  <img src="https://github.com/Big-Lolo/Ark4de-I0/blob/main/assets/images/robot2.jpg" alt="Robot Control System" width="200"/>
  <br>
  <em>Cartesian spider robot in operation during gameplay</em>
</p>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Ark4de I0 Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
