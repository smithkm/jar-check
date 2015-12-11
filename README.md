# jar-check

Check that a GeoServer WAR contains jars with revisions that match the submodules of the specified suite repository

    ruby geoserver-war-check.rb path-to-geoserver.war path-to-suite-repository

Check that the jars in a zip file of geoserver extensions have revisions that match the submodules of the specified suite repository

    ruby ext-check.rb path-to-extensions.zip path-to-suite-repository
