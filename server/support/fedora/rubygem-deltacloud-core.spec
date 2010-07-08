%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname deltacloud-core
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary: Deltacloud REST API
Name: rubygem-%{gemname}
Version: 0.0.1
Release: 2%{?dist}
Group: Development/Languages
License: ASL 2.0 and MIT
URL: http://www.deltacloud.org
Source0: http://gems.rubyforge.org/gems/%{gemname}-%{version}.gem
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: rubygems
Requires: ruby(abi) = 1.8
Requires: rubygem(eventmachine) >= 0.12.10
Requires: rubygem(haml) >= 2.2.17
Requires: rubygem(sinatra) >= 0.9.4
Requires: rubygem(rack) >= 1.0.0
Requires: rubygem(thin) >= 1.2.5
Requires: rubygem(builder) >= 2.1.2
Requires: rubygem(json) >= 1.2.3
BuildRequires: ruby-json >= 1.1.9
BuildRequires: rubygem(rake) >= 0.8.7
BuildRequires: rubygem(rack-test) >= 0.4.0
BuildRequires: rubygem(cucumber) >= 0.4.0
BuildRequires: rubygem(rcov) >= 0.9.6
BuildRequires: rubygems
BuildRequires: ruby(abi) = 1.8
BuildArch: noarch
Provides: rubygem(%{gemname}) = %{version}

%description
The Deltacloud API is built as a service-based REST API.
You do not directly link a Deltacloud library into your program to use it.
Instead, a client speaks the Deltacloud API over HTTP to a server
which implements the REST interface.

%prep

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{gemdir}
gem install --local --install-dir %{buildroot}%{gemdir} \
            --force --rdoc %{SOURCE0}
mkdir -p %{buildroot}/%{_bindir}
mv %{buildroot}%{geminstdir}/support/fedora/deltacloudd %{buildroot}/%{geminstdir}/bin
mv %{buildroot}%{gemdir}/bin/* %{buildroot}/%{_bindir}
rmdir %{buildroot}%{gemdir}/bin
find %{buildroot}%{geminstdir}/bin -type f | xargs chmod a+x

# Needs json_pure gem / not available in Fedora yet
#%check
#pushd %{buildroot}%{geminstdir}
#cucumber features/*.feature
#popd

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
%{_bindir}/deltacloudd
%{gemdir}/gems/%{gemname}-%{version}/bin
%{gemdir}/gems/%{gemname}-%{version}/lib
%{gemdir}/gems/%{gemname}-%{version}/public/favicon.ico
%{gemdir}/gems/%{gemname}-%{version}/public/images
%{gemdir}/gems/%{gemname}-%{version}/public/stylesheets
%{gemdir}/gems/%{gemname}-%{version}/tests
%{gemdir}/gems/%{gemname}-%{version}/views
%{gemdir}/gems/%{gemname}-%{version}/Rakefile
%{gemdir}/gems/%{gemname}-%{version}/*.rb
%{gemdir}/gems/%{gemname}-%{version}/config.ru
%doc %{gemdir}/gems/%{gemname}-%{version}/support/fedora
%doc %{gemdir}/gems/%{gemname}-%{version}/COPYING
%doc %{gemdir}/doc/%{gemname}-%{version}
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec
# MIT
%{gemdir}/gems/%{gemname}-%{version}/public/javascripts

%changelog
* Mon Apr 26 2010 Michal Fojtik <mfojtik@packager> - 0.0.1-1
- Initial package

* Mon Apr 26 2010 Michal Fojtik <mfojtik@packager> - 0.0.1-2
- Fixed broken dependencies
- Added new launcher for Fedora
