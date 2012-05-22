from distutils.core import setup

VERSION='0.0.1'

setup(name='deltacloud-client',
      version=VERSION,
      description='Python client wrapper for Deltacloud API',
      author='Michal Fojtik',
      author_email='mfojtik@redhat.com',
      license='GPLv2',
      url='http://deltacloud.apache.org/',
      py_modules=[ 'deltacloud' ]
      )
