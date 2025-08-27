import argparse
import astropy.io.fits
from astropy import time, coordinates as coord, units as u
import numpy as np

def read_evt(evt):
    with astropy.io.fits.open(evt) as hdulist:
        hdu = hdulist['events']
        data = hdu.data
        hdr = hdu.header
        ra = hdr['ra_targ']
        dec = hdr['dec_targ']
        mjd = hdr['mjdref'] + data['time']/86400
        return ra, dec, mjd

def helio(args):
    ra, dec, mjd = read_evt(args.evt)
    ip_peg = coord.SkyCoord(ra, dec, unit=u.deg)
    greenwich = coord.EarthLocation.of_site('greenwich')
    times = time.Time(mjd, format='mjd')
    ltt_helio = times.light_travel_time(ip_peg, 'heliocentric',
                                        location=greenwich)
    print(ltt_helio)

def main():
    parser = argparse.ArgumentParser(
        description='Convert event times to heliocentric JD',
    )
    parser.add_argument('evt', help='EVT file.')
    args = parser.parse_args()
    helio(args)

if __name__ == '__main__':
    main()
