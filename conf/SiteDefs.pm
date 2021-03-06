=head1 LICENSE

Copyright [2009-2014] EMBL-European Bioinformatics Institute

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

package EG::Common::SiteDefs;
use strict;

use Data::Dumper;

sub update_conf {
  map {delete($SiteDefs::__species_aliases{$_}) } keys %SiteDefs::__species_aliases;

  $SiteDefs::ENSEMBL_COHORT = 'EnsemblGenomes';
  
  $SiteDefs::SITE_RELEASE_VERSION = 38;
  $SiteDefs::SITE_RELEASE_DATE    = 'December 2017';
  $SiteDefs::SITE_MISSION         = 'Ensembl Genomes provides integrated access to genome-scale data from invertebrate metazoa, plants, fungi, protists and bacteria in partnership with the scientifc communities that work in each domain.';
    
  @SiteDefs::ENSEMBL_PERL_DIRS    = (
    $SiteDefs::ENSEMBL_WEBROOT.'/perl',
    $SiteDefs::ENSEMBL_SERVERROOT.'/eg-web-common/perl',
  );

  push @$SiteDefs::ENSEMBL_API_LIBS, $SiteDefs::ENSEMBL_SERVERROOT . '/ensemblgenomes-api/modules';

  $SiteDefs::PERL_RLIMIT_AS = '8192:16384';

  $SiteDefs::ENSEMBL_MIN_SPARE_SERVERS =  5;
  $SiteDefs::ENSEMBL_MAX_SPARE_SERVERS = 20;
  $SiteDefs::APACHE_BIN    = '/usr/sbin/httpd';
  $SiteDefs::APACHE_DIR    = '/etc/httpd';
  $SiteDefs::ENSEMBL_MAX_PROCESS_SIZE = 850000; # Kill httpd over 850000KB
  $SiteDefs::DATAFILE_BASE_PATH  = '';

  # Does this site have a large species set?
  # (used by the interface to determine whether to use dropdown or auto-comeplete etc)
  $SiteDefs::LARGE_SPECIES_SET = 0;

  # disable sprite maps - not used for EG
  $SiteDefs::ENSEMBL_DEBUG_IMAGES = 1;
  
  #---------------------------------------------------------------------------- 
  # TOOLS
  #----------------------------------------------------------------------------

  # Database key name for tools db as defined in MULTI.ini
  $SiteDefs::ENSEMBL_ORM_DATABASES->{'ticket'} = 'DATABASE_WEB_TOOLS';

  # use NcbiBlast dispatcher
  $SiteDefs::ENSEMBL_TOOLS_JOB_DISPATCHER->{Blast} = 'NcbiBlast';

  # if enabled, the BLAST form will try to look sequences up from external dbs
  # best to diable for EG
  $SiteDefs::ENSEMBL_BLAST_BY_SEQID = 0;

  # EG doesn't use file chameleon
  $SiteDefs::ENSEMBL_FC_ENABLED = 0;

  #----------------------------------------------------------------------------
  # EXTERNAL
  #----------------------------------------------------------------------------

  # REST endpoints
  $SiteDefs::NCBIBLAST_REST_ENDPOINT = 'http://www.ebi.ac.uk/Tools/services/rest/ncbiblast';
  $SiteDefs::EBEYE_REST_ENDPOINT     = 'https://www.ebi.ac.uk/ebisearch/ws/rest';

  # EG rest server
  $SiteDefs::ENSEMBL_REST_DOC_URL = 'http://ensemblgenomes.org/info/access/rest';
  $SiteDefs::Pathway              = 1; #enabling pathway widget
}


1;

