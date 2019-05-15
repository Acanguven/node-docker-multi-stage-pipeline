import {Writable} from "stream";

const calculator = (pipe: Writable, digits = 5)  => {
    let q = 1n, r = 0n, t = 1n, k = 1n, n = 3n, l = 3n;
    while (digits > 0) {
        if (q * 4n + r - t < n * t) {
            digits--;
            pipe.write(n.toString());
            let nr = (r - n * t) * 10n;
            n = (q * 3n + r) * 10n / t - n * 10n;
            q = q * 10n;
            r = nr;
        } else {
            let nr = (q * 2n + r) * l;
            let nn = (q * k * 7n + 2n + r * l) / (t * l);
            q = q * k;
            t = t * l;
            l = l + 2n;
            k = k + 1n;
            n = nn;
            r = nr;
        }
    }
};

export {
    calculator
}
