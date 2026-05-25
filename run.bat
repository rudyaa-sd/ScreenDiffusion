@echo off
title Launching ScreenDiffusion

echo Starting ScreenDiffusion...

:: Activate the virtual environment
call venv\Scripts\activate.bat

:: Run the main Python script
python main_gpu_addon.py

:: Keep the window open if the application crashes
pause