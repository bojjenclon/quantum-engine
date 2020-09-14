let project = new Project('Quantum Engine');

project.addSources('Sources');
project.addAssets('Assets/**');

project.addLibrary('uuid');
project.addLibrary('signals');
project.addLibrary('differ');
project.addLibrary('zui');

resolve(project);
