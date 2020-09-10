let project = new Project('Quantum Engine');

project.addAssets('Assets/**');
project.addSources('Sources');

project.addLibrary('signals');

resolve(project);
