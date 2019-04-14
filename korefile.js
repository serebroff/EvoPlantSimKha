let fs = require('fs');
let path = require('path');
let project = new Project('EvoPlantSim');
project.targetOptions = {"html5":{},"flash":{},"android":{},"ios":{}};
project.setDebugDir('build/windows');
await project.addProject('build/windows-build');
await project.addProject('d:/Projects/kodestudio_sasha/Kode/resources/app/extensions/kha/Kha');
resolve(project);
