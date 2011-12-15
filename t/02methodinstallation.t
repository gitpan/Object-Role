use Test::More tests => 10;

{
	package Local::MyRole;
	use base qw/Object::Role/;
	sub import
	{
		my ($class,  @args) = @_;
		my ($caller, %args) = __PACKAGE__->parse_arguments(@args);
		__PACKAGE__->install_method(somefunc => sub{1}, $caller);
	}
}

{
	package Local::MyClass;
	BEGIN { Local::MyRole->import }
	sub new { bless \@_, shift }
}

{
	package main;
	
	my $obj = Local::MyClass->new;
	
	ok(Local::MyRole->isa('Object::Role'), 'Local::MyRole isa Object::Role');
	ok(!Local::Class->isa('Object::Role'), 'NOT Local::MyClass isa Object::Role');
	ok(Local::MyRole->has_consumer('Local::MyClass'), 'Local::MyRole has_consumer Local::MyClass');
	ok(!Local::MyRole->has_consumer('base'), 'NOT Local::MyRole has_consumer base');
	ok(!Local::MyRole->has_consumer('Object::Role'), 'NOT Local::MyRole has_consumer Object::Role');
	ok(!Local::MyRole->has_consumer('Local::MyRole'), 'NOT Local::MyRole has_consumer Local::MyRole');
	ok(!Local::MyRole->can('somefunc'), 'NOT Local::MyRole can somefunc');
	ok(Local::MyClass->can('somefunc'), 'Local::MyClass can somefunc');
	ok($obj->can('somefunc'), 'Local::MyClass instance can somefunc');
	ok($obj->somefunc, 'somefunc works');
}
