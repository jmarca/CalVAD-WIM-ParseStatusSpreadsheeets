# Parse Status Spreadsheets

Perl code that parses the spreadsheets produced by Caltrans to note
WIM monthly status

Just the library, not the executable script.

# Installation

To install, use Dist::Zilla.

## prereqs

First install Dist::Zilla using cpan or cpanm

```
cpanm --sudo Dist::Zilla
```

Next install the Dist::Zilla plugins needed.

```
dzil authordeps --missing | cpanm --sudo
```

Next install the package dependencies, which are probably the
Spreadsheet parsing modules.

```
dzil listdeps --missing | cpanm --sudo
```

## Testing

To run the tests, you can also use dzil

```
dzil test
```

If the tests don't pass, read the failing messages, and maybe try to
run each test individually using prove, like so:

```
prove -l t/parse2011.t
```

(The -l flag on prove will add the packages under the 'lib' directory
to the Perl path.)

## Install

Once the prerequisites are installed and the tests pass, you can
install.  This will again run the tests.

Two ways to do this.  First is to use sudo -E

```
sudo -E dzil install
```

The second is to use cpanm as the install command.

```
dzil install --install-command "cpanm --sudo ."
```

I prefer the second way.  You have to be sudo to install the module
in the global perl library, but there is no need to be sudo to run the
tests.  This second way uses the "sudo" flag for cpanm only when
installing, not for testing.
