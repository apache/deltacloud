%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname deltacloud-core
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary: Deltacloud REST API
Name: rubygem-%{gemname}
Version: 0.3.0
Release: 1%{?dist}
Group: Development/Languages
License: ASL 2.0 and MIT
URL: http://incubator.apache.org/deltacloud
Source0: http://gems.rubyforge.org/gems/%{gemname}-%{version}.gem
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: rubygems
Requires: ruby(abi) = 1.8
Requires: rubygem(haml)
Requires: rubygem(sinatra) >= 1.0
Requires: rubygem(rack) >= 1.1.0
Requires: rubygem(thin)
Requires: rubygem(json) >= 1.4.0
Requires(post): chkconfig
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(postun): initscripts
BuildRequires: rubygems
BuildRequires: ruby(abi) = 1.8
BuildRequires: rubygem(json) >= 1.4.0
BuildRequires: rubygem(rake) >= 0.8.7
BuildRequires: rubygem(rack-test) >= 0.5.0
BuildRequires: rubygem(rspec) >= 1.3.0
BuildArch: noarch
Provides: rubygem(%{gemname}) = %{version}

%description
The Deltacloud API is built as a service-based REST API.
You do not directly link a Deltacloud library into your program to use it.
Instead, a client speaks the Deltacloud API over HTTP to a server
which implements the REST interface.

%package doc
Summary: Documentation for %{name}
Group: Documentation
Requires:%{name} = %{version}-%{release}

%description doc
Documentation for %{name}

%prep

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{gemdir}
mkdir -p %{buildroot}%{_initddir}
gem install --local --install-dir %{buildroot}%{gemdir} \
            --force --rdoc %{SOURCE0}
mkdir -p %{buildroot}/%{_bindir}
mkdir -p %{buildroot}/config
mv %{buildroot}%{gemdir}/bin/* %{buildroot}/%{_bindir}
mv %{buildroot}%{geminstdir}/support/fedora/%{gemname} %{buildroot}%{_initddir}
mv -f %{buildroot}%{geminstdir}/support/fedora/deltacloudd %{buildroot}%{geminstdir}/bin
rmdir %{buildroot}%{gemdir}/bin
find %{buildroot}%{geminstdir}/bin -type f | xargs chmod 755
find %{buildroot}%{geminstdir}/lib -type f | xargs chmod -x
chmod 755 %{buildroot}%{_initddir}/%{gemname}

%check
pushd %{geminstdir}
rake test:mock
popd

%clean
rm -rf %{buildroot}

%post
# This adds the proper /etc/rc*.d links for the script
/sbin/chkconfig --add %{gemname}

%preun
if [ $1 -eq 0 ] ; then
    /sbin/service %{gemname} stop >/dev/null 2>&1
    /sbin/chkconfig --del %{gemname}
fi

%postun
if [ "$1" -ge "1" ] ; then
    /sbin/service %{gemname} condrestart >/dev/null 2>&1 || :
fi

%files
%defattr(-, root, root, -)
%{_initddir}/%{gemname}
%{_bindir}/deltacloudd
%dir %{geminstdir}/
%{geminstdir}/bin
%{geminstdir}/LICENSE
%{geminstdir}/NOTICE
%{geminstdir}/DISCLAIMER
%{geminstdir}/config.ru
%{geminstdir}/*.rb
%{geminstdir}/Rakefile
%{geminstdir}/views
%{geminstdir}/lib
%{geminstdir}/public/images
%{geminstdir}/public/stylesheets
%{geminstdir}/public/favicon.ico
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec
%{geminstdir}/config/drivers.yaml
# MIT
%{gemdir}/gems/%{gemname}-%{version}/public/javascripts

%files doc
%defattr(-, root, root, -)
%{gemdir}/doc/%{gemname}-%{version}
%{geminstdir}/tests
%{geminstdir}/support
%{geminstdir}/%{gemname}.gemspec

%changelog
* Fri Apr  8 2011 David Lutterkort <lutter@redhat.com> - 0.3.0-1
- - Renamed COPYING to LICENSE, include NOTICE and DISCLAIMER

* Mon Jan 31 2011 Michal Fojtik <mfojtik@redhat.com> - 0.2.0-1
- Initial package
