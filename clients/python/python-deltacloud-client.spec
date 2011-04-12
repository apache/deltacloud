%if 0%{?fedora} > 12 || 0%{?rhel} > 6
%global with_python3 1
%else
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print (get_python_lib())")}
%endif

%global srcname python-deltacloud-client

Name:           python-deltacloud-client
Version:        0.0.1
Release:        1%{?dist}
Summary:        Deltacloud API client for Python
Group:          Applications/System
License:        ASL 2.0
URL:            http://incubator.apache.org/deltacloud
Source0:        http://incubator.apache.org/deltacloud/clients/%{srcname}-%{version}.tar.gz
BuildArch:      noarch
Requires:       python2
Requires:       libxml2-python
Requires:       python(httplib2)

%description
Python REST client library used for communication with Deltacloud API

%if 0%{?with_python3}
%package -n python3-deltacloud-client
Summary:        Deltacloud API client for Python
Group:          Applications/System

%description -n python3-deltacloud-client
Python REST client library used for communication with Deltacloud API
%endif # with_python3

%prep
%setup -q -n %{srcname}-%{version}

%build
CFLAGS="$RPM_OPT_FLAGS" %{__python} setup.py build

%install
rm -rf %{buildroot}
%{__python} setup.py install --skip-build --root $RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%{python_sitelib}/*

%changelog

* Thu Mar 31 2011 Michal Fojtik <mfojtik@redhat.com> - 0.0.1-1
Initial import
