process XENIUMRANGER_IMPORT_SEGMENTATION {
    tag "$meta.id"
    label 'process_high'

    // container ""

    input:
    path xenium_path
    path geometry

    output:
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "XENIUMRANGER_IMPORT_SEGMENTATION module does not support Conda. Please use Docker / Singularity / Podman instead."
    }
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    def transcript_assignment ? "--transcript-assignment=${transcript_assignment}": ""
    def coordinate_transform ? "--coordinate-transform=${coordinate_transform}": ""
    """
    xeniumranger import-segmentation \\
        --id=${meta.id} \\
        --xenium-bundle=${xenium_path} \\
        --nuclei=${geometry} \\
        --cells=${geometry} \\
        --units=${units} \\
        ${transcript_assignment} \\
        ${coordinate_transform}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        xeniumranger: \$(xeniumranger -V | sed -e "s/xeniumranger xeniumranger-//g")
    END_VERSIONS
    """

    stub:
    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "XENIUMRANGER_IMPORT_SEGMENTATION module does not support Conda. Please use Docker / Singularity / Podman instead."
    }
    """
    mkdir -p outs/
    touch outs/fake_file.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        xeniumranger: \$(xeniumranger -V | sed -e "s/xeniumranger xeniumranger-//g")
    END_VERSIONS
    """
}