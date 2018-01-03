
================
Kalliope Formula
================

Kalliope is a modular always-on voice controlled personal assistant designed
for home automation.


Sample Pillars
==============

Single kalliope service with synapses defined

.. code-block:: yaml

    kalliope:
      server:
        enabled: true
        bind:
          address: 0.0.0.0
          port: 5000
        synapse:
          default-synapse:
            signals:
            - order: "default-synapse"
            neurons:
            - say:
                message:
                - "I haven't understood"
                - "I don't know this order"
                - "I don't recognize that order"

Single kalliope service with extra resources defined

.. code-block:: yaml

    kalliope:
      server:
        enabled: true
        bind:
          address: 0.0.0.0
          port: 5000
        trigger:
          primary:
            engine: snowboy
            default: true
            pmdl_file: "trigger/kalliope-EN-12samples.pmdl"
        speech_to_text:
          google:
            engine: google
            language: "en-EN"
        text_to_speech:
          google:
            engine: google
            language: "en-EN"
        resource:
          hue:
            type: neuron
            source:
              engine: git
              address: https://github.com/kalliope-project/kalliope_neuron_hue.git

Kalliope server with Czech localization and synapse that tells local time

.. code-block:: yaml

    kalliope:
      server:
        enabled: true
        name: kalliope
        player:
          mplayer:
            default: true
            engine: mplayer
        bind:
          address: 0.0.0.0
          port: 5000
        random_wake_up_answers:
          - "čekám na vaše rozkazy"
          - "ano pane?"
          - "poslouchám"
          - "co pro vás mohu udělat?"
        on_ready_answers:
          - "čekám na vaše rozkazy"
        play_on_ready_notification: "never"
        language: cs
        speech_to_text:
          google:
            default: true
            engine: google
            language: "cs-CZ"
        text_to_speech:
          googletts:
            default: true
            engine: googletts
            language: "cs"
            cache: true
        synapse:
          say-local-time:
            signals:
              - order: "Kolik je hodin"
              - order: "Jaký je čas"
            neurons:
              - systemdate:
                  say_template:
                    - "Je {{ hours }} hodin a {{ minutes }} minut"

More Information
================

* https://github.com/kalliope-project/kalliope


Documentation and Bugs
======================

To learn how to install and update salt-formulas, consult the documentation
available online at:

    http://salt-formulas.readthedocs.io/

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate issue tracker. Use GitHub issue tracker for specific salt
formula:

    https://github.com/salt-formulas/salt-formula-kalliope/issues

For feature requests, bug reports or blueprints affecting entire ecosystem,
use Launchpad salt-formulas project:

    https://launchpad.net/salt-formulas

Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

You should also subscribe to mailing list (salt-formulas@freelists.org):

    https://www.freelists.org/list/salt-formulas

Any questions or feedback is always welcome so feel free to join our IRC
channel:

    #salt-formulas @ irc.freenode.net

Read more
=========

* links
