# Vtoán &middot; [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/your/your-project/blob/master/LICENSE)  
> A math practice and memory game application.  

This project is a Windows desktop application designed to help users practice math and memory skills through various game modes.  

## Installing / Getting started  

To run the application, execute `Vtoán.exe`.  

The application will start in the main menu.  

## Developing  

### Built With  
*   Pascal (Delphi/Free Pascal with SDL2 bindings)  
*   SDL2: Core multimedia library  
*   SDL2_image: Image loading support  
*   SDL2_ttf: TrueType Font rendering support  
*   SDL2_mixer: Audio mixing support  

### Prerequisites  
*   Windows Operating System  
*   SDL2 runtime libraries (included in the project folder)  

### Setting up Dev  

1.  Clone the repository:  
    ```shell  
    git clone https://github.com/your/your-project.git  
    cd your-project/  
    ```  
2.  Open `mathreal2.pas` in a Pascal IDE (e.g., Free Pascal Lazarus).  
3.  Ensure all DLLs (libFLAC-8.dll, libfreetype-6.dll, libjpeg-9.dll, libmodplug-1.dll, libmpg123-0.dll, libogg-0.dll, libopus-0.dll, libopusfile-0.dll, libpng16-16.dll, libtiff-5.dll, libvorbis-0.dll, libvorbisfile-3.dll, libwebp-7.dll, SDL2_image.dll, SDL2_mixer.dll, SDL2_ttf.dll, SDL2.dll, zlib1.dll) are present in the project's root directory or accessible via system PATH.  
4.  Ensure `VBAMASN.TTF` font file is present in the root directory.  

### Building  

Compile `mathreal2.pas` using a Pascal compiler (e.g., Free Pascal Compiler) targeting Windows GUI application.  

```shell  
fpc -WM -FE. mathreal2.pas  
```  

This will generate `Vtoán.exe` along with a resource file.  

### Deploying / Publishing  
Copy the `Vtoán.exe` executable along with all `.dll` files, `VBAMASN.TTF`, `Huong dan.docx`, and the `hethong` and `hinh` folders to the deployment environment.  

## Versioning  

This project does not currently follow a formal versioning scheme.  

## Configuration  

The application's settings (FPS, screen mode) are configured via `hethong\setting.txt`.  
*   `setting.txt` content:  
    ```  
    <FPS_value>  
    <screen_mode>  
    ```  
    Example:  
    ```  
    60  
    full  
    ```  
    `FPS_value` can be adjusted in the in-game settings.  
    `screen_mode` can be `full` for fullscreen or `thuong` (normal) for windowed mode.  

## Tests  

No automated tests are currently implemented. Manual testing is performed.  

## Style guide  

The code adheres to Pascal's standard syntax and uses a mix of Vietnamese and English for variable and procedure names.  

## Api Reference  

This project does not expose an external API.  

## Database  

No external database is used. Game data, such as questions and answers, are dynamically generated or loaded from text files (`.txt`) within the `hethong` folder. Configuration settings are stored in `hethong\setting.txt`.  

## Licensing  

This project is licensed under the MIT License. See the `LICENSE` file for full details.
