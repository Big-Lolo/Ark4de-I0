# Ark4de I0

## Project Description

Ark4de I0 is a final robotics assignment project that showcases the integration of robotics, computer vision, and interactive gaming. This project features a cartesian spider robot programmed to create an arcade-style interactive game where players control the robot to collect objects and score points.

The system combines real-time robot control with computer vision analysis to create an engaging gaming experience. Players can interact with the robot through multiple control methods while the system tracks their performance and maintains a scoreboard.

## Control Options

### PlayStation 4 Controller
- Connect your PS4 controller via USB or Bluetooth
- Use analog sticks and buttons for precise robot control

### Keyboard Controls
- **WASD Keys**: Move robot along X and Y axes
- **Arrow Keys**: Control robot height (Z-axis) and rotation
  - Up Arrow: Raise crane
  - Down Arrow: Lower crane  
  - Left Arrow: Rotate crane left
  - Right Arrow: Rotate crane right
- **N**: Open crane/gripper
- **M**: Close crane/gripper
- **L**: Toggle robot light

## Technologies Used

- **MATLAB**: Main programming language for robot control and game logic
- **Computer Vision**: Real-time image processing and object detection for scoring
- **HTML/JavaScript**: Frontend user interface for arcade experience
- **Tailwind CSS**: Modern styling framework for responsive UI design

## Requirements

### Hardware
- Cartesian spider robot with 5-axis control
- USB camera for computer vision
- Computer with MATLAB installed
- Optional: PlayStation 4 controller

### Software
- MATLAB (R2019b or later recommended)
- Computer Vision Toolbox
- Image Processing Toolbox
- Modern web browser (Chrome, Firefox, Safari)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Big-Lolo/Ark4de-I0.git
   cd Ark4de-I0
   ```

2. Ensure MATLAB is installed with required toolboxes:
   - Computer Vision Toolbox
   - Image Processing Toolbox

3. Connect your cartesian robot via USB/serial connection

4. Connect the USB camera to your computer

5. (Optional) Connect PlayStation 4 controller

## Usage

1. Open MATLAB and navigate to the project directory

2. Run the main application:
   ```matlab
   arkade = ARK4DE();
   ```

3. The arcade interface will open in a new window

4. Configure robot connection settings if needed

5. Click "START" to begin the game

6. Use your preferred control method (PS4 controller or keyboard) to:
   - Move the robot to collect objects
   - Position objects in designated areas
   - Maximize your score within the time limit

7. View your results on the scoreboard

## Gallery

### Game Interface
![Game Interface](assets/images/image1.png)

### Robot in Action
![Robot in Action](assets/images/image2.png)

*Note: The arcade interface features a modern design with real-time camera feed and intuitive controls for an engaging gaming experience.*

## License

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
