# $Header: /raid/cvsroot/DBIx/DBIx-SearchBuilder/SearchBuilder/Handle.pm,v 1.2 2000/08/30 18:46:48 jesse Exp $
package DBIx::SearchBuilder::Handle;
use Carp;
use DBI;
use strict;
use vars qw($VERSION @ISA $DBIHandle);


$VERSION = '0.02';



#instantiate a new object.
# {{{ sub new 
sub new  {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self  = {};
  bless ($self, $class);
  #we have no limit statements. DoSearch won't work.
  return ($self);
}
# }}}

# {{{ sub Connect 
sub Connect  {
  my $self = shift;
  
  my %args = ( Driver => undef,
	       Database => undef,
	       Host => 'localhost',
	       User => undef,
	       Password => undef,
	       @_);
  
  my $dsn;
  
  $dsn = "dbi:$args{'Driver'}:$args{'Database'}:$args{'Host'}";
  
  $DBIHandle = DBI->connect_cached($dsn, $args{'User'}, $args{'Password'}) || croak "Connect Failed $DBI::errstr\n" ;


  $self->dbh->{RaiseError}=1;
  $self->dbh->{PrintError}=1;
  return (1); 
}
# }}}

# {{{ sub Disconnect 

sub Disconnect  {
  my $self = shift;
  return ($self->dbh->disconnect());
}

# {{{ sub Handle / dbh 
sub dbh {
  my $self=shift;
  return($DBIHandle);
}

*Handle=\&dbh;
# }}}

# {{{ sub UpdateTableValue 

sub UpdateTableValue  {
  my $self = shift;
  
  my $Table = shift;
  my $Col = shift;
  my $NewValue = shift;
  my $Record = shift;
  my $is_sql = shift;
  my $QueryString;
  
  # quote the value
  # TODO: We need some general way to escape SQL functions.
  $NewValue=$self->safe_quote($NewValue) unless ($is_sql);
  # build the query string
  $QueryString = "UPDATE $Table SET $Col = $NewValue WHERE id = $Record";
  
  
  my $sth = $self->dbh->prepare($QueryString);
  if (!$sth) {
    
    if ($main::debug) {
      die "Error:" . $self->dbh->errstr . "\n";
    }
    else {
      return (0);
  }
  }
  if (!$sth->execute) {
    if ($self->{'debug'}) {
      die "Error:" . $sth->errstr . "\n";
    }
    else {
      return(0);
    }
    
  }
  
  return (1); #Update Succeded
}

# }}}



# {{{ sub SimpleQuery

sub SimpleQuery  {
  my $self = shift;
  my $QueryString = shift;
  # TODO update the last edited 
  
  my $sth = $self->dbh->prepare($QueryString);
  if (!$sth) {
    if ($main::debug) {
      die "Error:" . $self->dbh->errstr . "\n";
    }
    else {
      return (0);
    }
  }
  if (!$sth->execute) {
    if ($self->{'debug'}) {
      die "Error:" . $sth->errstr . "\n";
    }
    else {
      return(0);
    }
    
  }
  return ($sth);
  
}

# }}}

# {{{ sub FetchResult

=head2 FetchResult

Takes a SELECT query as a string.
Returns the first row as an array

=cut 

sub FetchResult {
  my $self = shift;
  my $query = shift;
  my $sth = $self->SimpleQuery($query);

  return ($sth->fetchrow);
}
# }}}

# {{{ sub safe_quote 

sub safe_quote  {
   my $self = shift;
   my $in_val = shift;
   my ($out_val);
   if (!$in_val) {
     return ("''");
     
   }
   else {
     $out_val = $self->dbh->quote($in_val);
     
   }
   return("$out_val");
   
}

# }}}
 
 
 
# Autoload methods go after =cut, and are processed by the autosplit program.
 
 1;
__END__

# {{{ POD

=head1 NAME

DBIx::SearchBuilder::Handle - Perl extension which is a generic DBI handle

=head1 SYNOPSIS

  use DBIx::SearchBuilder::Handle;

 my $Handle = DBIx::SearchBuilder::Handle->new();
 $Handle->Connect( Driver => 'mysql',
		   Database => 'dbname',
		   Host => 'hostname',
		   User => 'dbuser',
		   Password => 'dbpassword');
 
 

=head1 DESCRIPTION

Jesse's a slacker.

Blah blah blah.

=head1 AUTHOR

Jesse Vincent, jesse@fsck.com

=head1 SEE ALSO

perl(1), DBIx::SearchBuilder

=cut

# }}} POD

