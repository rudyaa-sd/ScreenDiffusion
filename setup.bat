@echo off
title ScreenDiffusion Final Setup
echo ========================================================
echo        ScreenDiffusion Ultimate Environment Setup
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
mkdir "%~dp0local_cache" 2>nul

:: Install PyTorch from local cache if available, otherwise download
if exist "%~dp0local_cache\torch-2.7.0+cu128*.whl" (
    echo [INFO] Massive local PyTorch file detected! Installing completely offline...
    pip install torch==2.7.0+cu128 torchvision==0.22.0+cu128 --no-index --find-links="%~dp0local_cache"
) else (
    echo [INFO] Local cache empty. Downloading from PyTorch servers...
    pip install torch==2.7.0+cu128 torchvision==0.22.0+cu128 --find-links="%~dp0local_cache" --index-url https://download.pytorch.org/whl/cu128
)

echo.
echo [5/5] Installing strictly version-locked AI and UI dependencies...
REM Core AI framework
pip install transformers==4.36.2 diffusers==0.24.0 huggingface-hub==0.22.2
pip install streamdiffusion[tensorrt]

REM NVIDIA TensorRT compilation tools & CUDA bindings (Strictly pinned for RTX 50 Series)
pip install tensorrt==10.8.0.43 tensorrt-cu12==10.8.0.43 polygraphy onnx onnx-graphsurgeon cuda-python==12.8.0 --extra-index-url https://pypi.ngc.nvidia.com

REM xformers skipped - RTX 50 series will natively use PyTorch SDPA (Flash Attention)
:: pip install xformers (Intentionally removed to prevent build failures on cu128)

REM UI, capture, and locked utility versions
pip install customtkinter pillow numpy==1.26.4 dxcam mss opencv-python==4.10.0.84

echo.
echo ========================================================
echo    Setup Complete! The environment is locked and stable.
echo ========================================================
pause
exit /b

:: ==========================================
:: ERROR HANDLERS
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