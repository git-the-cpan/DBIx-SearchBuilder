# $Header: /raid/cvsroot/DBIx/DBIx-SearchBuilder/SearchBuilder/Handle/mysql.pm,v 1.4 2001/01/11 00:05:13 jesse Exp $

package DBIx::SearchBuilder::Handle::mysql;
use DBIx::SearchBuilder::Handle;
@ISA = qw(DBIx::SearchBuilder::Handle);




# {{{ sub Insert

=head2 Insert

Takes a table name as the first argument and assumes that the rest of the arguments
are an array of key-value pairs to be inserted.

=cut

sub Insert  {
    my $self = shift;

    my $sth = $self->SUPER::Insert(@_);
    if (!$sth) {
       if ($main::debug) {
       	die "Error with $QueryString: ". $self->dbh->errstr;
      }
       else {
	    return (0);
       }
     }

    $self->{'id'}=$self->dbh->{'mysql_insertid'};
    warn "$self no row id returned on row creation" unless ($self->{'id'});
    return( $self->{'id'}); #Add Succeded. return the id
  }

# }}}



=head1 NAME

  DBIx::SearchBuilder::Handle::mysql -- a mysql specific Handle object

=head1 SYNOPSIS


  =head1 DESCRIPTION

=head1 AUTHOR

Jesse Vincent, jesse@fsck.com

=head1 SEE ALSO

perl(1), DBIx::SearchBuilder

=cut
