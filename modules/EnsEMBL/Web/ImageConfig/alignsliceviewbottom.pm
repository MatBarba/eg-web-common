=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package EnsEMBL::Web::ImageConfig::alignsliceviewbottom;

use strict;
use previous qw(init);

sub init {
  my $self = shift;
  $self->PREV::init(@_);
  
  # set spritelib for the EG division - TODO: make this configurable
  my $site = $SiteDefs::ENSEMBL_SITETYPE =~ s/Ensembl //r; #/
  my $sp_img_48 = $self->species_defs->ENSEMBL_SERVERROOT . '/eg-web-' . lc($site) . '/htdocs/i/species/48'; # 
  if(-e $sp_img_48) {
    $self->set_parameters({ spritelib => {
      %{$self->get_parameter('spritelib')||{}},
      species => $sp_img_48,
    }});
  }
}


1;
