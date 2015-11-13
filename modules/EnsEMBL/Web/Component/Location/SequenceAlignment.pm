=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

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

package EnsEMBL::Web::Component::Location::SequenceAlignment;


sub content {
  my $self      = shift;
  my $object    = $self->object;
  my $threshold = 50001;
  
  return $self->_warning('Region too large', '<p>The region selected is too large to display in this view - use the navigation above to zoom in...</p>') if $object->length > $threshold;
  
  my $hub            = $self->hub;
  my $species_defs   = $hub->species_defs;
  my $original_slice = $object->slice;
     $original_slice = $original_slice->invert if $hub->param('strand') == -1;
  my $ref_slice      = $self->new_object('Slice', $original_slice, $object->__data); # Get reference slice
  my $var_db         = $species_defs->databases->{'DATABASE_VARIATION'};
  my $strain         = $species_defs->translate('strain') || 'strain';
  my (@samples, $html);
    
  my $config = {
    display_width  => $hub->param('display_width') || 60,
    site_type      => ucfirst(lc $species_defs->ENSEMBL_SITETYPE) || 'Ensembl',
    species        => $hub->species,
    comparison     => 1,
    resequencing   => 1,
    ref_slice_name => $ref_slice->get_samples('reference')
  };
  
  foreach (qw(exon_ori match_display snp_display line_numbering codons_display title_display)) {
    $config->{$_} = $hub->param($_) unless $hub->param($_) eq 'off';
  }
  
  # FIXME: Nasty hack to allow the parameter to be defined, but false. Used when getting variations.
  # Can be deleted once we get the correct set of variations from the API 
  # (there are currently variations returned when the resequenced samples match the reference)
  $config->{'match_display'} ||= 0;  
  $config->{'exon_display'}    = 'selected' if $config->{'exon_ori'};
  $config->{'end_number'}      = $config->{'number'} = 1 if $config->{'line_numbering'};
  
  foreach (qw(DEFAULT_STRAINS DISPLAY_STRAINS)) {
    foreach my $sample (@{$var_db->{$_}}) {
      push @samples, $sample if $hub->param($sample) eq 'yes';
    }
  }
  
  if (scalar @samples) {
    $config->{'slices'} = $self->get_slices($ref_slice->Obj, \@samples, $config);
    
    my ($sequence, $markup) = $self->get_sequence_data($config->{'slices'}, $config);
    
    # Order is important for the key to be displayed correctly
    $self->markup_exons($sequence, $markup, $config)     if $config->{'exon_display'};
    $self->markup_codons($sequence, $markup, $config)    if $config->{'codons_display'};
    $self->markup_variation($sequence, $markup, $config) if $config->{'snp_display'};
    $self->markup_comparisons($sequence, $markup, $config); # Always called in this view
    $self->markup_line_numbers($sequence, $config)       if $config->{'line_numbering'};
    
    my $slice_name = $original_slice->name;
    
    my (undef, undef, $region, $start, $end) = split ':', $slice_name;
    my $url = $hub->url({ action => 'View', r => "$region:$start-$end" });

    $config->{'html_template'} = qq(<p><b>$config->{'species'}</b>&nbsp;&gt;&nbsp;<a href="$url">$slice_name</a></p><pre>%s</pre>);
    
    $html  = $self->build_sequence($sequence, $config);
    $html .= $self->_hint(
      'strain_config', 
      ucfirst "$strain configuration",
      qq(<p>You can choose which ${strain}s to display from the "<b>Resequenced ${strain}s</b>" section of the configuration panel, accessible via the "<b>Configure this page</b>" link to the left.</p>)
    );
  } else {
    $strain .= 's';
    
    if ($ref_slice->get_samples('reseq')) {
      $html = $self->_info(
        "No $strain specified", 
        qq(<p>Please select $strain to display from the "<b>Resequenced $strain</b>" section of the configuration panel, accessible via "<b>Configure this page</b>" link to the left.</p>)
      );
    } else {
      $html = $self->_warning("No $strain available", "<p>No resequenced $strain available for this species</p>");
    }
  }
  
  return $html;
}

1;