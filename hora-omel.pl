# Convertir fecha y hora al timestamp que requiere Postgresql YYYY-MM-DD HH:MM:SS
sub ConvierteFecha()
{
        my ($fecha, $hora, $formato) = @_;
        my $sfechautc;

        # Desglosar 25/12/1974
        my ($anyo,$mes,$dia) = split('-', $fecha);

        # Hora puede venir como "9", "09" o "9:12:45"
        $hora = (split(':', $hora))[0] if ($hora =~ /:/);
        # Convertir "7" en "07".
        $hora = sprintf"%02d", $hora;



        # Formato OMEL: la hora es hora local en Espa�a, pero los d�as
        # de cambio de hora, tienen 23 o 25 horas. Por tanto, para cada hora
        # debemos calcular su equivalente en hora local.
        # La hora viene expresada de 1 a 24(25) y no de 00 a 23.
        # Es decir, la hora 24 es lo que se ha producido entre las 23h y las 24h,
        # osea, la hora 00h del d�a siguiente.
        # Como las funciones "date" no valen para esos dos d�as, lo que haremos
        # ser� llamar a date pas�ndole las 00h y luego le iremos sumando horas a
        # esa fecha, que ya estar� en UTC.
        # TODO: Cachear fechas para que sea mas r�pido, ya que Date::Manip es lento.
        if ($formato eq 'omel')
        {
                my $hora00 = sprintf("%02d", $hora - 1);

                # Determinar si est� en horario de verano o de invierno
                my $ZONA=&DeduceDST("OMEL", $anyo, $mes, $dia, $hora00, 0);
                #print "$anyo-$mes-$dia $hora00:00  ZONA: ($ZONA)\n";

                my $fecha00 = &ParseDate("$anyo$mes$dia"."0000 $ZONA");
                $fecha00 = &DateCalc($fecha00, "+ $hora hours");
                $sfechautc = &UnixDate($fecha00, '%Y-%m-%d %H:%M:%S');
                #print "FECHA: $anyo-$mes-$dia ${hora}h OMEL --> $sfechautc  $ZONA\n";
        }
        elsif ($formato eq 'espa�a')
        {
                # Determinar si est� en horario de verano o de invierno
                my $ZONA=&DeduceDST("CET", $anyo, $mes, $dia, $hora, 0);

                # Calcular la hora UTC.
                $sfechautc = &UnixDate("$anyo$mes$dia${hora}00 $ZONA", '%Y-%m-%d %H:%M:%S');
                #print "FECHA: $anyo-$mes-$dia ${hora}h ESPA�A --> $sfechautc  $ZONA\n";
        }
        # Por defecto, asumimos que es hora UTC
        else
        {
                $sfechautc = &UnixDate("$anyo$mes$dia${hora}00", '%Y-%m-%d %H:%M:%S');
        }


        return $sfechautc;
}

# A partir de una zona horaria base y una fecha y hora, deducir si existe horario de verano o no.
sub DeduceDST()
{
        my ($ZONA, $anyo, $mes, $dia, $hora, $minuto) = @_;
        my $dstbegins;
        my $dstends;

        # En Espa�a, se cambia la hora entre las 02:00 y las 03:00h
        # En OMEL, se cambia a las 00h del d�a siguiente, y el d�a problema tiene 23 o 25 horas.

        if ($ZONA eq 'CET')
        {
                # Si es una zona que tiene DST (daylight saving time), comprobar si la fecha y hora est�n en
                # verano o no.
                $dstbegins=&ParseDate("last Sunday in March $anyo at 03:00");
                $dstends=&ParseDate("last Sunday in October $anyo at 02:00");
        }
        elsif ($ZONA eq 'OMEL')
        {
                $dstbegins=&ParseDate("last Sunday in March $anyo at 00:00");
                $dstends=&ParseDate("last Sunday in October $anyo at 00:00");

                $dstbegins=&DateCalc($dstbegins, "+1 day");
                $dstends=&DateCalc($dstends, "+1 day");
        }
        else
        {
                die "ZONA DESCONOCIDA ($ZONA)";
        }


        my $fecha=&ParseDate("$anyo$mes$dia$hora".'00');
        #print "($dstbegins) ($fecha) ($dstends) /$hora/\n";

        # Si fecha es anterior a inicio de verano.
        return 'CET' if (&Date_Cmp($fecha, $dstbegins) < 0);
        return 'CET' if (&Date_Cmp($fecha, $dstends) >= 0);

        # Estamos en horario de verano. Calcular la zona equivalente.
        $ZONA='CEST';

        return $ZONA;
}

