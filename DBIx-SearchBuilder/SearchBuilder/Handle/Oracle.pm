# $Header: /raid/cvsroot/DBIx/DBIx-SearchBuilder/SearchBuilder/Handle/Oracle.pm,v 1.3 2000/09/07 04:28:15 jesse Exp $

package DBIx::SearchBuilder::Handle::Oracle;
use DBIx::SearchBuilder::Handle;
@ISA = qw(DBIx::SearchBuilder::Handle);



sub new  {
      my $proto = shift;
      my $class = ref($proto) || $proto;
      my $self  = {};
      bless ($self, $class);
      return ($self);
}


=head2 Connect

Connect takes a hashref and passes it off to SUPER::Connect;
it returns a database handle.

=cut
  
sub Connect {
    my $self = shift;
    
    $self->SUPER::Connect(@_);
    
    $self->dbh->{LongTruncOk}=1;
    $self->dbh->{LongReadLen}=8000;
    
    $self->dbh->SimpleQuery("ALTER SESSION set NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS'");
    
    return ($Handle); 
}
# }}}

# {{{ sub Insert

=head2 Insert

Takes a table name as the first argument and assumes that the rest of the arguments
are an array of key-value pairs to be inserted.

=cut

sub Insert  {
	my $self = shift;
	my $table = shift;
 my @keyvalpairs = (@_);
    my ($cols, $vals);
    
    while (my $key = shift @keyvalpairs) {
      my $value = shift @keyvalpairs;
      $cols .= $key . ", ";
      if (defined ($value)) {
	  $value = $self->safe_quote($value)
	      unless ($key=~/^(Created|LastUpdated)$/ && $value=~/^now\(\)$/i);
	  $vals .= "$value, ";
      }
      else {
	$vals .= "NULL, ";
      }
    }	
    
    $cols =~ s/, $//;
    $vals =~ s/, $//;
    #TODO Check to make sure the key's not already listed.
    #TODO update internal data structure
    my $QueryString = "INSERT INTO ".$self->{'table'}." ($cols) VALUES ($vals)";
    my $sth = $self->SimpleQuery($QueryString);
    if (!$sth) {
       if ($main::debug) {
	die "Error with $QueryString";
      }
       else {
	 return (0);
       }
     }

 # Oracle Hack to replace non-supported mysql_rowid call
 
    $QueryString = "SELECT ".$self->{'table'}."_NUM.currval FROM DUAL";
 
    $sth = $self->SimpleQuery($QueryString);
    if (!$sth) {
       if ($main::debug) {
	die "Error with $QueryString";
      }
       else {
	 return (0);
       }
     }
 #probably better/more efficient way to do following
 #needs error checking
     my @row = $sth->fetchrow_array;
     $self->{'id'}=$row[0];
    return( $self->{'id'}); #Add Succeded. return the id
  }



=head1 NAME

  DBIx::SearchBuilder::Handle::Oracle -- an oracle specific Handle object

=head1 SYNOPSIS


  =head1 DESCRIPTION

=head1 AUTHOR

Jesse Vincent, jesse@fsck.com

=head1 SEE ALSO

perl(1), DBIx::SearchBuilder

=cut
