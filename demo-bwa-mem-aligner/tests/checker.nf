#!/usr/bin/env nextflow

/*
 * Copyright (c) 2019-2021, Ontario Institute for Cancer Research (OICR).
 *                                                                                                               
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

/*
 * Contributors:
 *   Junjun Zhang <junjun.zhang@oicr.on.ca>
 */


nextflow.enable.dsl=2

params.input_bam = "input/?????_?.lane.bam"
params.aligned_lane_prefix = 'grch38-aligned'
params.ref_genome_gz = "reference/tiny-grch38-chr11-530001-537000.fa.gz"
params.sequencing_experiment_metadata = "NO_FILE"
params.tempdir = "NO_DIR"
params.publish_dir = ""

include { bwaMemAligner } from '../bwa-mem-aligner' params(params)
include { getBwaSecondaryFiles } from './wfpr_modules/github.com/icgc-argo/wfpr/demo-utils@1.0.0/main.nf'


Channel
  .fromPath(params.input_bam, checkIfExists: true)
  .set { input_bam_ch }

Channel
  .fromPath(getBwaSecondaryFiles(params.ref_genome_gz), checkIfExists: true)
  .set { ref_genome_gz_idx_ch }


// will not run when import as module
workflow {
  main:
    bwaMemAligner(
      input_bam_ch.flatten(),
      file(params.ref_genome_gz),
      ref_genome_gz_idx_ch.collect(),
      file(params.sequencing_experiment_metadata),
      file(params.tempdir),
      true
    )
}
