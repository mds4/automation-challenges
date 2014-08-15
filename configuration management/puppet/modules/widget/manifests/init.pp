class widget {
  # install the templated widgetfile on the system
  file {
    "/etc/widgetfile":
      content  => template("widget/widgetfile.erb"),
      mode     => 0644,
      owner    => root,
      group    => root;
  }
}