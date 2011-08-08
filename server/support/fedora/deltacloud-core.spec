%global app_root %{_datadir}/%{name}

Summary: Deltacloud REST API
Name: deltacloud-core
Version: 0.3.0
Release: 12%{?dist}
Group: Development/Languages
License: ASL 2.0 and MIT
URL: http://incubator.apache.org/deltacloud
Source0: http://gems.rubyforge.org/gems/%{name}-%{version}.gem
Source1: deltacloudd-fedora
Source2: deltacloud-core
Source3: deltacloud-core-config
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: rubygems
Requires: ruby(abi) = 1.8
Requires: rubygem(haml)
Requires: rubygem(sinatra) >= 1.0
Requires: rubygem(rack) >= 1.1.0
Requires: rubygem(thin)
Requires: rubygem(net-ssh)
Requires: rubygem(json) >= 1.4.0
Requires: rubygem(rack-accept)
Requires: rubygem(nokogiri)
Requires(post):   chkconfig
Requires(preun):  chkconfig
Requires(preun):  initscripts
Requires(postun): initscripts
BuildRequires: rubygems
BuildRequires: ruby(abi) = 1.8
BuildRequires: rubygem(haml)
BuildRequires: rubygem(sinatra) >= 1.0
BuildRequires: rubygem(nokogiri)
BuildRequires: rubygem(net-ssh)
BuildRequires: rubygem(aws)
BuildRequires: rubygem(rack-accept)
BuildRequires: rubygem(rake) >= 0.8.7
BuildRequires: rubygem(rack) >= 1.1.0
BuildRequires: rubygem(rack-test) >= 0.5.0
BuildRequires: rubygem(rspec) >= 1.3.0
BuildRequires: rubygem(json) >= 1.4.0
BuildArch: noarch
Obsoletes: rubygem-deltacloud-core
Provides: rubygem(deltacloud-core)

%description
The Deltacloud API is built as a service-based REST API.
You do not directly link a Deltacloud library into your program to use it.
Instead, a client speaks the Deltacloud API over HTTP to a server
which implements the REST interface.

%package doc
Summary: Documentation for %{name}
Group: Documentation
Requires: %{name} = %{version}-%{release}

%description doc
Documentation for %{name}

%package all
Summary: Deltacloud Core with all drivers
Requires: %{name} = %{version}-%{release}
Requires: deltacloud-core-azure
Requires: deltacloud-core-ec2
Requires: deltacloud-core-gogrid
Requires: deltacloud-core-mock
Requires: deltacloud-core-opennebula
Requires: deltacloud-core-rackspace
Requires: deltacloud-core-rhevm
Requires: deltacloud-core-rimuhosting
Requires: deltacloud-core-sbc
Requires: deltacloud-core-terremark

%description all
Deltacloud core with all available drivers

%package azure
Summary: Deltacloud Core for Azure
Requires: %{name} = %{version}-%{release}
Requires: rubygem(waz-blobs)

%description azure
The azure sub-package brings in all dependencies necessary to use deltacloud
core to connect to Azure.

%package ec2
Summary: Deltacloud Core for EC2
Requires: %{name} = %{version}-%{release}
Requires: rubygem(aws)

%description ec2
The ec2 sub-package brings in all dependencies necessary to use deltacloud
core to connect to EC2.

%package gogrid
Summary: Deltacloud Core for GoGrid
Requires: %{name} = %{version}-%{release}

%description gogrid
The gogrid sub-package brings in all dependencies necessary to use deltacloud
core to connect to GoGrid.

%package mock
Summary: Deltacloud Core for Mock
Requires: %{name} = %{version}-%{release}

%description mock
The mock sub-package brings in all dependencies necessary to use deltacloud
core to connect to Mock.

%package opennebula
Summary: Deltacloud Core for OpenNebula
Requires: %{name} = %{version}-%{release}

%description opennebula
The opennebula sub-package brings in all dependencies necessary to use
deltacloud core to connect to OpenNebula.

%package rackspace
Summary: Deltacloud Core for Rackspace
Requires: %{name} = %{version}-%{release}
Requires: rubygem(cloudfiles)
Requires: rubygem(cloudservers)

%description rackspace
The rackspace sub-package brings in all dependencies necessary to use deltacloud
core to connect to Rackspace.

%package rhevm
Summary: Deltacloud Core for RHEV-M
Requires: %{name} = %{version}-%{release}
Requires: rubygem(rest-client)

%description rhevm
The rhevm sub-package brings in all dependencies necessary to use deltacloud
core to connect to RHEV-M.

%package rimuhosting
Summary: Deltacloud Core for Rimuhosting
Requires: %{name} = %{version}-%{release}

%description rimuhosting
The rimuhosting sub-package brings in all dependencies necessary to use
deltacloud core to connect to Rimuhosting.

%package sbc
Summary: Deltacloud Core for SBC
Requires: %{name} = %{version}-%{release}

%description sbc
The sbc sub-package brings in all dependencies necessary to use deltacloud core
to connect to SBC.

%package terremark
Summary: Deltacloud Core for Terremark
Requires: %{name} = %{version}-%{release}
Requires: rubygem(fog)
Requires: rubygem(excon)

%description terremark
The terremark sub-package brings in all dependencies necessary to use deltacloud
core to connect to Terremark.

%prep
%setup -q -c -T
gem unpack -V --target=%{_builddir} %{SOURCE0}
pushd %{_builddir}/%{name}-%{version}
popd

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{app_root}
mkdir -p %{buildroot}%{_initddir}
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_sysconfdir}/sysconfig
cp -r %{_builddir}/%{name}-%{version}/* %{buildroot}%{app_root}
install -m 0755 %{SOURCE1} %{buildroot}%{_bindir}/deltacloudd
install -m 0755 %{SOURCE2} %{buildroot}%{_initddir}/%{name}
install -m 0655 %{SOURCE3} %{buildroot}%{_sysconfdir}/sysconfig/%{name}
find %{buildroot}%{app_root}/lib -type f | xargs chmod -x
chmod -x %{buildroot}%{_sysconfdir}/sysconfig/%{name}
chmod 0755 %{buildroot}%{_initddir}/%{name}
chmod 0755 %{buildroot}%{app_root}/bin/deltacloudd
rm -rf %{buildroot}%{app_root}/support
rdoc --op %{buildroot}%{_defaultdocdir}/%{name}

%check
pushd %{buildroot}%{app_root}
rake test:mock
popd

%clean

%post
# This adds the proper /etc/rc*.d links for the script
/sbin/chkconfig --add %{name}

%preun
if [ $1 -eq 0 ] ; then
    /sbin/service %{name} stop >/dev/null 2>&1
    /sbin/chkconfig --del %{name}
fi

%postun
if [ "$1" -ge "1" ] ; then
    /sbin/service %{name} condrestart >/dev/null 2>&1 || :
fi

%files
%defattr(-, root, root, -)
%{_initddir}/%{name}
%{_bindir}/deltacloudd
%config(noreplace) %{_sysconfdir}/sysconfig/%{name}
%dir %{app_root}/
%{app_root}/bin
%{app_root}/config.ru
%{app_root}/*.rb
%{app_root}/views
%{app_root}/lib
%{app_root}/config
%dir %{app_root}/public
%{app_root}/public/images
%{app_root}/public/stylesheets
%{app_root}/public/favicon.ico
%doc %{app_root}/DISCLAIMER
%doc %{app_root}/NOTICE
%doc %{app_root}/LICENSE
# MIT
%{app_root}/public/javascripts

%files doc
%defattr(-, root, root, -)
%{_defaultdocdir}/%{name}
%{app_root}/tests
%{app_root}/%{name}.gemspec
%{app_root}/Rakefile

%files all
%defattr(-, root, root, -)

%files azure
%defattr(-, root, root, -)

%files ec2
%defattr(-, root, root, -)

%files gogrid
%defattr(-, root, root, -)

%files mock
%defattr(-, root, root, -)

%files opennebula
%defattr(-, root, root, -)

%files rackspace
%defattr(-, root, root, -)

%files rhevm
%defattr(-, root, root, -)

%files rimuhosting
%defattr(-, root, root, -)

%files sbc
%defattr(-, root, root, -)

%files terremark
%defattr(-, root, root, -)

%changelog
* Mon Aug 01 2011 Chris Lalancette <clalance@redhat.com> - 0.3.0-12
- Add the -all package

* Tue May 31 2011 Chris Lalancette <clalance@redhat.com> - 0.3.0-8
- Create sub-packages to bring in dependencies

* Tue May 31 2011 Michal Fojtik <mfojtik@redhat.com> - 0.3.0-7
- Added default config file in /etc/sysconfig/deltacloud-core

* Tue May 31 2011 Michal Fojtik <mfojtik@redhat.com> - 0.3.0-6
- Updated init.d script to match Fedora Guidelines

* Fri May 20 2011 Michal Fojtik <mfojtik@redhat.com> - 0.3.0-5
- Obsoleted rubygem-deltacloud-core

* Wed May 11 2011 Michal Fojtik <mfojtik@redhat.com> - 0.3.0-4
- Fixed memory calculation for RHEV-M (client)

* Wed May 11 2011 Michal Fojtik <mfojtik@redhat.com> - 0.3.0-3
- Fixed loadbalancer bug

* Thu May 5 2011 Michal Fojtik <mfojtik@redhat.com> - 0.3.0-2
- Fixed documentation generation
- Replaced moving with copying
- Removed support folder from doc subpackage

* Fri Apr 29 2011 Michal Fojtik <mfojtik@redhat.com> - 0.3.0-1
- Version bump

* Tue Mar 15 2011 Michal Fojtik <mfojtik@redhat.com> - 0.2.0-4
- Added missing runtime dependencies

* Mon Jan 31 2011 Michal Fojtik <mfojtik@redhat.com> - 0.2.0-3
- Removed cache and specification
- Added Sinatra to build dependecies

* Mon Jan 31 2011 Michal Fojtik <mfojtik@redhat.com> - 0.2.0-2
- Moved application to app_root (https://fedoraproject.org/wiki/Packaging_talk:Ruby#Applications)

* Mon Jan 31 2011 Michal Fojtik <mfojtik@redhat.com> - 0.2.0-1
- Initial package
