#!/bin/bash

sh -c 'mvn clean compile assembly:single'

mv 'target/Anime4K-static.jar' 'Anime4K.jar'