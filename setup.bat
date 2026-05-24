@echo off
title ScreenDiffusion Setup
echo ========================================================
echo        ScreenDiffusion Environment Setup
echo ========================================================
echo.

echo [1/5] Checking for Python...
python --version
if %errorlevel% neq 0 goto :python_error

echo.
echo [2/5] Checking Virtual Environment...
if not exist venv\ goto :create_venv

echo [WARNING] A virtual environment (venv) already exists!
choice /C YN /M "Are you sure you want to delete it and reinstall everything?"
if errorlevel 2 goto :cancel_setup

echo Deleting existing venv for a clean install...
rmdir /s /q venv

:create_venv
echo Creating a fresh Virtual Environment (venv)...
python -m venv venv

echo.
echo [3/5] Activating venv and upgrading pip...
call venv\Scripts\activate
python -m pip install --upgrade pip

echo.
echo [4/5] Installing PyTorch with universal CUDA support...
echo Checking local caches to skip the massive download if possible...
mkdir "%~dp0local_cache" 2>nul

:: Check if the specific torch wheel physically exists in the local_cache folder
if exist "%~dp0local_cache\torch-2.7.0+cu128*.whl" (
    echo [INFO] Massive local PyTorch file detected! Installing completely offline...
    pip install torch==2.7.0+cu128 torchvision==0.22.0+cu128 --no-index --find-links="%~dp0local_cache"
) else (
    echo [INFO] Local cache empty. Downloading from PyTorch servers...
    pip install torch==2.7.0+cu128 torchvision==0.22.0+cu128 --find-links="%~dp0local_cache" --index-url https://download.pytorch.org/whl/cu128
)

echo.
echo [5/5] Installing strictly version-locked AI and UI dependencies...
REM This locks the exact versions that play nicely together for StreamDiffusion and TensorRT
pip install transformers==4.36.2 diffusers==0.24.0 huggingface-hub==0.22.2
pip install streamdiffusion[tensorrt]

REM Install the EXACT CUDA-enabled xformers version compatible with PyTorch 2.7.0+cu128
pip install xformers==0.0.31 --no-deps --index-url https://download.pytorch.org/whl/cu128

REM Installing UI and capture dependencies (NumPy locked to prevent xformers crash)
pip install customtkinter pillow numpy==1.26.4 dxcam mss opencv-python==4.10.0.84
echo.
echo ========================================================
echo    Setup Complete! The environment is locked and stable.
echo ========================================================
pause
exit /b

:: ==========================================
:: ERROR HANDLERS & EXITS
:: ==========================================

:python_error
echo.
echo [ERROR] Python is not installed or not in your system PATH.
pause
exit /b

:cancel_setup
echo.
echo Setup cancelled to protect your existing environment.
pause
exit /b