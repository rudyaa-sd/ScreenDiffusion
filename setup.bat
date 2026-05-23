@echo off
title ScreenDiffusion Setup
echo ==========================================
echo ScreenDiffusion Environment Setup
echo ==========================================

:: Check if Python is accessible
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not added to your system PATH.
    echo Please install Python 3.10+ and try again.
    pause
    exit /b
)

:: Create the virtual environment
echo.
echo [1/5] Creating virtual environment (venv)...
python -m venv venv

:: Activate the virtual environment
echo.
echo [2/5] Activating virtual environment...
call venv\Scripts\activate.bat

:: Upgrade pip to avoid installation errors
echo.
echo [3/5] Upgrading pip...
python -m pip install --upgrade pip

:: Install specific PyTorch versions (CUDA 12.4)
echo.
echo [4/5] Installing PyTorch 2.5.1 (CUDA 12.4)...
pip install torch==2.5.1+cu124 torchvision==0.20.1+cu124 --index-url https://download.pytorch.org/whl/cu124

:: Install remaining dependencies and StreamDiffusion
echo.
echo [5/5] Installing core dependencies and StreamDiffusion...
pip install customtkinter Pillow numpy mss dxcam diffusers transformers huggingface_hub xformers
:: For CUDA 12, we must explicitly install the CUDA 12 TensorRT packages
pip install tensorrt-cu12 tensorrt-cu12-bindings tensorrt-cu12-libs
pip install streamdiffusion[tensorrt]

echo.
echo ==========================================
echo Setup Complete! 
echo ==========================================
echo To start the application in the future, you can run these two commands:
echo 1. venv\Scripts\activate
echo 2. python main_gpu_addon.py
echo.
pause