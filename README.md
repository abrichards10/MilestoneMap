# MilestoneMap

## Overview

The MilestoneMap provides a visual representation of goals and their steps in a mapped circle structure. Users can input text into circles, which represent goals and tasks, and visually manage these goals with features such as adding, removing, and moving circles. The app supports zooming, panning, and focus management for an optimal user experience.

## Features

### Mapped Circle Structure

- **Visual Representation**: Goals are displayed as large circles, and steps to achieve these goals are represented as incrementally smaller circles.
- **Dynamic Circle Size**: Circles representing goals are larger, while task circles are smaller, visually indicating their hierarchy.

### Circle Management

- **Add Circle**: Users can add new circles connected to the selected circle. New circles are placed above the parent circle, connected by a faint line.
- **Remove Circle**: Provides an option to remove a circle. When a circle with children is removed, its children will disappear, except for the end goal, which attaches to the parent circle.
- **Move Circle**: Users can drag a circle to another circle, making it a child of the target circle. The children of the moved circle also move with it.

### Circle Options

- **Edit Circle**: Modify the text and other properties of a circle.
- **Declare Goal Size**: Option to mark a circle as a large or small goal.
- **Set Date**: Users can date a circle, and dated circles will show up on a calendar in a separate page.

### Navigation & Interaction

- **Zoom and Pan**: Users can zoom in and out and pan across the screen to view circles. The space for circles is large to accommodate various levels of detail.
- **Focus Button**: A button located in the bottom right corner allows users to snap the view back to the main circle if they get lost.
- **Navbar Visibility**: The navbar hides when the user scrolls down and reappears when scrolling up.

## Installation

To get started with the Goals App, follow these steps:

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/goals_app.git
   cd goals_app
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the App**

   ```bash
   flutter run
   ```

## Usage

### Adding Circles

1. Tap on a circle to select it.
2. Use the "Add Circle" option from the context menu.
3. Enter the text for the new circle and confirm.

### Removing Circles

1. Tap on the circle you want to remove.
2. Choose the "Remove Circle" option from the context menu.
3. Confirm the removal in the dialog.

### Moving Circles

1. Tap and hold a circle to drag it.
2. Move it over another circle to make it a child of that circle.
3. Release to drop the circle into place.

### Editing Circles

1. Tap on the circle to select it.
2. Choose the "Edit Circle" option from the context menu.
3. Modify the text and properties and save changes.

### Declaring Goals and Setting Dates

1. Use the "Edit Circle" option to declare whether the circle is a large or small goal.
2. Set dates for goals, which will be displayed on the calendar page.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes.
