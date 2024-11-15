Dummy Role
=========

Just creates a file in given path with given content

Requirements
------------

Requires dummy_collection.dummy_module

Role Variables
--------------

| Name | Description |
|------|-------------|
| path | The path where file with content will be created |
| content | content of the file |


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, path: some-path/some-file.txt, content: "Have a nice day!" }

License
-------

BSD
