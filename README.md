# Cursor IDE Linux Installer/Updater Script

This script automates the download, installation, and setup of the [Cursor IDE](https://cursor.com/) AppImage on Linux systems. It also creates a `.desktop` file for easy integration with your desktop environment's application menu.

## Features

*   **Fetches Latest Version:** Retrieves the download URL for the latest stable Linux (x64) version of Cursor IDE directly from their API.
*   **Downloads AppImage:** Downloads the AppImage using `wget` with a progress bar.
*   **Installs to User Directory:** Installs the AppImage to a user-configurable directory (default: `~/apps/cursor-ide/` or `~/Applications/cursor-ide/` depending on your script version).
*   **Makes Executable:** Sets the executable permission for the AppImage.
*   **Downloads Icon:** Fetches an official icon for Cursor and places it alongside the AppImage.
*   **Creates Desktop Entry:** Generates a `.desktop` file in `~/.local/share/applications/`, allowing Cursor IDE to appear in your application launcher/menu.
*   **Updates Desktop Database:** Attempts to update the desktop entry database so the new entry appears immediately.
*   **Dependency Checks:** Verifies the presence of `jq`, `curl`, and `wget` before proceeding.

## Prerequisites

Before running the script, ensure you have the following command-line utilities installed:

*   **`jq`**: A lightweight and flexible command-line JSON processor.
    *   Debian/Ubuntu: `sudo apt update && sudo apt install jq`
    *   Fedora: `sudo dnf install jq`
    *   Arch Linux: `sudo pacman -S jq`
*   **`curl`**: A tool to transfer data from or to a server.
    *   Debian/Ubuntu: `sudo apt update && sudo apt install curl`
    *   Fedora: `sudo dnf install curl`
    *   Arch Linux: `sudo pacman -S curl`
*   **`wget`**: A utility for non-interactive download of files from the Web.
    *   Debian/Ubuntu: `sudo apt update && sudo apt install wget`
    *   Fedora: `sudo dnf install wget`
    *   Arch Linux: `sudo pacman -S wget`

## Usage

1.  **Save the Script:**
    Save the script content to a file, for example, `install_cursor_ide.sh`.

2.  **Make it Executable:**
    Open your terminal and navigate to the directory where you saved the script. Then run:
    ```bash
    chmod +x install_cursor_ide.sh
    ```

3.  **Run the Script:**
    Execute the script:
    ```bash
    ./install_cursor_ide.sh
    ```

The script will then:
*   Check for dependencies.
*   Fetch the download URL.
*   Download the Cursor IDE AppImage.
*   Create the installation directory (if it doesn't exist).
*   Move and rename the AppImage.
*   Make the AppImage executable.
*   Download the icon.
*   Create the `.desktop` file.
*   Attempt to update your desktop application database.

## Configuration

You can customize a few paths at the beginning of the script if needed:

*   `APPDIR`: The main directory where the Cursor AppImage and icon will be stored.
    *   Default example: `APPDIR="${HOME}/apps/cursor-ide"`
    *   Your current version: `APPDIR="${HOME}/Applications/cursor-ide"`
*   `FINAL_APPIMAGE_NAME`: The name of the AppImage file once installed.
    *   Default: `FINAL_APPIMAGE_NAME="cursor-ide.AppImage"`
*   `ICON_FILENAME`: The name for the downloaded icon file.
    *   Default: `ICON_FILENAME="cursor-ide.png"`
*   `ICON_URL`: The URL from which the icon is downloaded.
    *   Default: `https://raw.githubusercontent.com/getcursor/cursor/main/apps/stable/static/icon.png`
*   `DESKTOP_FILE_DIR`: The directory where the `.desktop` file will be created.
    *   Default: `DESKTOP_FILE_DIR="${HOME}/.local/share/applications"`
*   `DESKTOP_FILE_NAME`: The name of the `.desktop` file.
    *   Default: `DESKTOP_FILE_NAME="cursor-ide.desktop"`

## After Installation

*   **Running Cursor IDE:**
    *   You should be able to find "Cursor AI IDE" (or similar) in your desktop environment's application menu.
    *   You can also run it directly from the terminal:
        ```bash
        ${HOME}/Applications/cursor-ide/cursor-ide.AppImage
        ```
        (Adjust the path if you changed `APPDIR`).
    *   If `${APPDIR}` is added to your system's `PATH`, you might be able to run it by just typing `cursor-ide.AppImage`.

*   **Desktop Entry Not Appearing?**
    If the "Cursor AI IDE" entry doesn't appear in your application menu immediately, try logging out and logging back into your desktop session. Alternatively, you can try running the following command manually in your terminal:
    ```bash
    update-desktop-database ~/.local/share/applications/
    ```

## Notes

*   The script uses `wget --progress=bar:force` for downloading, which attempts to show a progress bar.
*   The `.desktop` file includes the `--no-sandbox` flag for the `Exec` command. This is a common requirement or workaround for some AppImages, especially those based on Electron, to function correctly in certain environments.
*   The `StartupWMClass=Cursor` in the `.desktop` file is an assumption. If window grouping or icon association in your dock/taskbar doesn't work correctly, you might need to find the correct `WM_CLASS` for Cursor (e.g., using `xprop WM_CLASS` and clicking on a Cursor window) and update the `.desktop` file.

---

Feel free to modify this README to better suit any specific details or instructions you'd like to add.
