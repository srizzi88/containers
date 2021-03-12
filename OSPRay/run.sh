#!/bin/bash

docker run -p 127.0.0.1:8000:8000 -it --mount type=bind,source=/usr,target=/ussr srizzi/paraview-ospray
