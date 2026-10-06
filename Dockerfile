RUN mv /usr/bin/chown /usr/bin/chown.real && mv /usr/bin/chgrp /usr/bin/chgrp.real && \
    printf '#!/bin/sh\n/usr/bin/chown.real "$@" 2>/dev/null || true\n' > /usr/bin/chown && \
    printf '#!/bin/sh\n/usr/bin/chgrp.real "$@" 2>/dev/null || true\n' > /usr/bin/chgrp && \
    chmod 0755 /usr/bin/chown /usr/bin/chgrp
