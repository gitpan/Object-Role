package Object::Role;

use 5.006;
use strict;

BEGIN {
	$Object::Role::AUTHORITY = 'cpan:TOBYINK';
	$Object::Role::VERSION   = '0.001';
}

use Sub::Name qw/subname/;

BEGIN {
	eval 'use Object::AUTHORITY; 1' or do {
		*AUTHORITY = sub { $Object::Role::AUTHORITY }
	}
}

sub parse_arguments
{
	my (undef, $default, @args) = @_;
	my %args;
	
	while (defined(my $arg = shift @args))
	{
		if ($arg =~ /^-/)
		{
			$args{$arg} = shift @args;
		}
		else
		{
			push @{$args{$default}}, $arg;
		}
	}
	
	my $caller = defined $args{-package} ? $args{-package} : caller(1);
	
	return ($caller, %args);
}

sub install_method
{
	my ($class, $subname, $coderef, $caller) = @_;
	my $name = "$caller\::$subname";
	no strict 'refs';
	no warnings 'redefine';
	*{$name} = subname($name, $coderef);
	$class->register_consumer($caller)
		unless $class->has_consumer($caller);
	$class;
}

sub register_consumer
{
	my ($class, $consumer) = @_;
	no strict 'refs';
	no warnings 'redefine';
	push @{"$class\::CONSUMERS"}, $consumer;
	$class;
}

sub has_consumer
{
	my ($class, $consumer) = @_;
	$consumer = ref($consumer) if ref($consumer);
	no strict 'refs';
	no warnings 'redefine';
	foreach (@{"$class\::CONSUMERS"})
	{
		return $class if $_ eq $consumer;
	}
	return;
}

1;

__END__

=head1 NAME

Object::Role - base class for non-Moose roles

=head1 SYNOPSIS

 {
   package Object::Dumpable;
   use base qw/Object::Role/;
   use Data::Dumper;
   sub import
   {
     my ($class, @args) = @_;
     my ($caller, %args) = __PACKAGE__->parse_arguments(undef, @args);
     my $coderef = sub
       {
         my ($self) = @_;
         return Dumper($self);
       };
     __PACKAGE__->install_method(dump => $coderef, $caller);
   }
 }
 
 {
   package Foo;
   use Object::Dumpable;
   sub new { ... }
 }
 
 {
   package main;
   my $foo = Foo->new;
   warn $foo->dump;
 }

=head1 DESCRIPTION

This will be better documented once I fully understand it myself!

The idea of this is to be a base class for roles like L<Object::DOES>,
L<Object::Stash> and L<Object::ID>. It handles parsing of import arguments,
installing methods into the caller's namespace (like L<Exporter>, but using
a technique that is immune to L<namespace::autoclean>) and tracking which
packages have consumed your role.

While C<Object::Role> is a base class for roles, it is not itself a role,
so does not export anything. Instead, your role must inherit from it.

=head2 Methods

=over

=item C<< parse_arguments($default_arg_name, @arguments) >>

Will parse:

  package My::Class;
  use My::Role -foo => 1, -bar => [2,3], 4, 5;

as:

  (
    'My::Class',   # caller,
    (
      '-foo'             => [1],
      '-bar'             => [2, 3],
      $default_arg_name  => [4, 5],
    )
  )

=item C<< install_method($subname => $coderef, $package) >>

Installs $coderef as "$package\::$subname".

Automatically calls register_consumer($package).

=item C<< register_consumer($package) >>

Records that $package has consumed (used) your role.

=item C<< has_consumer($package) >>

Check if $package has consumed (used) your role.

=back

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Object-Role>.

=head1 SEE ALSO

L<Object::DOES>, L<Object::AUTHORITY>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2011 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

