#!/bin/bash

# Only show this message in the live environment
if [ -d "/run/archiso" ] && [ "$(tty)" = "/dev/tty1" ]; then
    # Check if cowspace is already set up
    if ! /usr/local/bin/manage-cowspace | grep -q "resize"; then
        echo ""
        echo "================================================================="
        echo "  KALKI OS LIVE ENVIRONMENT"
        echo "================================================================="
        echo "  Current cowspace status:"
        /usr/local/bin/manage-cowspace
        echo ""
        echo "  To increase available space, run:"
        echo "    sudo /usr/local/bin/manage-cowspace -s 4"
        echo ""
        echo "  For more information, see: /usr/share/doc/live-environment/README.md"
        echo "================================================================="
        echo ""
    fi
fi
