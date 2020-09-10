let project = new Project('Quantum Engine');

project.addAssets('Assets/**');
project.addSources('Sources');

project.addLibrary('uuid');
project.addLibrary('signals');
project.addLibrary('differ');
project.addLibrary('zui');

resolve(project);
