%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global geminstdir %{gemdir}/gems/deltacloud-core-%{version}

Summary: Deltacloud REST API
Name: deltacloud-core
Version: 0.2.0
Release: 2%{?dist}
Group: Development/Languages
License: ASL 2.0 and MIT
URL: http://incubator.apache.org/deltacloud
Source0: http://gems.rubyforge.org/gems/deltacloud-core-%{version}.gem
# Note: This would be needed only for EPEL branches:
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: rubygems
Requires: ruby(abi) = 1.8
Requires: rubygem(haml)
Requires: rubygem(sinatra) >= 1.0
Requires: rubygem(rack) >= 1.1.0
Requires: rubygem(thin)
Requires: rubygem(haml)
Requires: rubygem(json) >= 1.4.0
Requires: rubygem(net-ssh) >= 2.0.0
Requires: rubygem(rack-accept)
Requires(post): chkconfig
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(postun): initscripts
BuildRequires: rubygems
BuildRequires: ruby(abi) = 1.8
BuildRequires: rubygem(sinatra) >= 1.0
BuildRequires: rubygem(haml)
BuildRequires: rubygem(rack) >= 1.1.0
BuildRequires: rubygem(nokogiri) >= 1.4.3
BuildRequires: rubygem(net-ssh) >= 2.0.0
BuildRequires: rubygem(rack-accept)
BuildRequires: rubygem(json) >= 1.4.0
BuildRequires: rubygem(rake) >= 0.8.7
BuildRequires: rubygem(rack-test) >= 0.5.0
BuildRequires: rubygem(rspec) >= 1.3.0
BuildArch: noarch
Provides: deltacloud-core = %{version}

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
mv %{buildroot}%{gemdir}/bin/* %{buildroot}/%{_bindir}
mv %{buildroot}%{geminstdir}/support/fedora/deltacloud-core %{buildroot}%{_initddir}
mv -f %{buildroot}%{geminstdir}/support/fedora/deltacloudd %{buildroot}%{geminstdir}/bin
rmdir %{buildroot}%{gemdir}/bin
find %{buildroot}%{geminstdir}/bin -type f | xargs chmod 755
find %{buildroot}%{geminstdir}/lib -type f | xargs chmod -x
chmod 755 %{buildroot}%{_initddir}/deltacloud-core

%check
pushd %{buildroot}%{geminstdir}
rake test
popd

%clean
rm -rf %{buildroot}

%post
# This adds the proper /etc/rc*.d links for the script
/sbin/chkconfig --add deltacloud-core

%preun
if [ $1 -eq 0 ] ; then
    /sbin/service deltacloud-core stop >/dev/null 2>&1
    /sbin/chkconfig --del deltacloud-core
fi

%postun
if [ "$1" -ge "1" ] ; then
    /sbin/service deltacloud-core condrestart >/dev/null 2>&1 || :
fi

%files
%defattr(-, root, root, -)
%{_initddir}/deltacloud-core
%{_bindir}/deltacloudd
%dir %{geminstdir}/
%{geminstdir}/bin
%{geminstdir}/COPYING
%{geminstdir}/config.ru
%{geminstdir}/*.rb
%{geminstdir}/Rakefile
%{geminstdir}/views
%{geminstdir}/lib
%{geminstdir}/public/images
%{geminstdir}/public/stylesheets
%{geminstdir}/public/favicon.ico
%{gemdir}/cache/deltacloud-core-%{version}.gem
%{gemdir}/specifications/deltacloud-core-%{version}.gemspec
# MIT
%{gemdir}/gems/deltacloud-core-%{version}/public/javascripts

%files doc
%defattr(-, root, root, -)
%{gemdir}/doc/deltacloud-core-%{version}
%{geminstdir}/tests
%{geminstdir}/support
%{geminstdir}/deltacloud-core.gemspec

%changelog
* Fri Feb 04 2011 Michal Fojtik <mfojtik@redhat.com> - 0.2.0-2
- Package renamed to deltacloud-core, since it's not library and it's providing
  full REST API server with init script.
- Fixed dependency issues
- Removed bundled gems and RPMs
- Fixed path in pushd inside tests section

* Mon Jan 31 2011 Michal Fojtik <mfojtik@redhat.com> - 0.2.0-1
- Initial package
