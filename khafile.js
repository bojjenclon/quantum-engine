let project = new Project('Quantum Engine');

project.addAssets('Assets/**');
project.addSources('Sources');

project.addLibrary('uuid');
project.addLibrary('signals');

resolve(project);
