{{ make_hdf5_cmd }} $MONTE_CARLO/forcing-yaml/{{ job_id }}-make-hdf5-{{ run_number }}.yaml {{ start_yyyy_mm_dd }} {{ n_days }} \
&& {{ mohid_cmd }} run --no-submit --tmp-run-dir $MONTE_CARLO/{{ job_id }}-{{ run_number }}/ \
  $MONTE_CARLO/mohid-yaml/{{ job_id }}-{{ run_number }}.yaml $MONTE_CARLO/results/{{ job_id }}-{{ run_number }}/ \
&& bash $MONTE_CARLO/{{ job_id }}-{{ run_number }}/MOHID.sh
rm -rf {{ forcing_dir }}/{{ job_id }}-{{ run_number }}/
