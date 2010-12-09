for f in   https://fez.education.ucsb.edu \
  https://fez.education.ucsb.edu/deezy \
  https://fez.education.ucsb.edu/deezy/public \
  https://deezy.education.ucsb.edu \
  https://deezy.education.ucsb.edu/public \
  https://deezy.education.ucsb.edu/javascripts \
  https://deezy.education.ucsb.edu/javascripts/application.js;
do
  GET -sd $f;
done

