Name:    statverif
Version: 1.97pl1
Release: 1
Summary: Automated Security Protocol Verifier
BuildRequires: ocaml-ocamlbuild,ocaml-findlib
Requires: ocaml

License: GPL
Source0: %{name}-%{version}.tar.gz

%description
Automated Security Protocol Verifier


%prep
%setup
%build
make
%install
make prefix=%{buildroot}%{_prefix} install
%files
%{_bindir}/*

%changelog
