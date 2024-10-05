import torch
import os
from huggingface_hub.constants import HF_HUB_CACHE

base_image = os.environ.get("diffusers__base")
if(not base_image):
    base_image = "stabilityai/stable-diffusion-xl-base-1.0" 
diffusers_config = {
    "vae": "madebyollin/sdxl-vae-fp16-fix",
    # "base": base_image,
    # "prompt": base_image,
    # "text2img": base_image,
    # "img2img": base_image,
    "canny_lora": "https://huggingface.co/stabilityai/control-lora/blob/main/control-LoRAs-rank256/control-lora-canny-rank256.safetensors",
    'common_args': {
        "torch_dtype": torch.float16,
        "use_safetensors": True,
        'variant':"fp16"
    },
    'use_refiner': False,
    'save_to_disk': True,
    'controlnet_image_resolution': 512,
    "base_settings": {
        'dreamturbo': {
            "guidance_scale": 3.5,
            'num_inference_steps': 8,
            'clip_skip': 2
        }
    },
    'model_settings': {
        'default': {
            'model': base_image,
            "scheduler": "DPMSolverMultistep",
        },
        'turbo':{
            "model":"stabilityai/sdxl-turbo"
        },
        'refiner':{
            'model':"stabilityai/stable-diffusion-xl-refiner-1.0"
        },
        'dreamturbo': {
            'model':f"{HF_HUB_CACHE}/dreamshaperXL_v21TurboDPMSDE.safetensors",
            'url': 'https://civitai.com/api/download/models/351306?type=Model&format=SafeTensor&size=full&fp=fp16',
            'scheduler': "DPMSolverMultistep",
            'vae': False
        },
        'canny': {
            'model': "diffusers/controlnet-canny-sdxl-1.0",
        }
    }
}
for key in diffusers_config:
    envValue = os.environ.get("diffusers__" + key)
    if envValue:
        diffusers_config[key] = envValue